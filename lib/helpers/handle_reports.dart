import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:roam_and_report/converters/report_status_converter.dart';
import 'package:roam_and_report/enums/report_status.dart';
import 'package:roam_and_report/models/report_model.dart';
import 'package:roam_and_report/models/vote_result.dart';

class HandleReports {
  static Stream<List<ReportModel>> getAllReportsStream(
    String? userid,
    bool filterByStatus,
    String? filter,
    String? location,
  ) {
    ReportStatus? status;
    if (filterByStatus) {
      status = ReportStatusConverter.stringToReportStatus(filter!);
    }
    if (location != null) {
      location = location.toLowerCase().trim();
    }

    Stream<QuerySnapshot<Map<String, dynamic>>> reportSnapshots;
    if (userid == null) {
      //not on user profile
      if (status == ReportStatus.Submitted) {
        //only retrieve submitted reports
        reportSnapshots = FirebaseFirestore.instance
            .collection('reports')
            .where('status', isEqualTo: ReportStatus.Submitted.toString())
            //.orderBy('likes', descending: true)
            //.orderBy('date', descending: true)
            .snapshots();
      } else if (status == ReportStatus.InProgress) {
        //only retrieve in progress reports
        reportSnapshots = FirebaseFirestore.instance
            .collection('reports')
            .where('status', isEqualTo: ReportStatus.InProgress.toString())
            //.orderBy('likes', descending: true)
            //.orderBy('date', descending: true)
            .snapshots();
      } else if (status == ReportStatus.Resolved) {
        reportSnapshots = FirebaseFirestore.instance
            .collection('reports')
            .where('status', isEqualTo: ReportStatus.Resolved.toString())
            //.orderBy('likes', descending: true)
            //.orderBy('date', descending: true)
            .snapshots();
      } else {
        if (filter != 'Likes' && filter != 'Date') {
          //filter by description type
          reportSnapshots = FirebaseFirestore.instance
              .collection('reports')
              .where('description', isEqualTo: filter)
              //.orderBy('likes', descending: true)
              //.orderBy('date', descending: true)
              .snapshots();
        } else if (location != null) {
          //find reports containing location name
          reportSnapshots = FirebaseFirestore.instance
              .collection('reports')
              .where('location keywords', arrayContains: location.split(' ')[0])
              //.orderBy('likes', descending: true)
              //.orderBy('date', descending: true)
              .snapshots();
        } else {
          //order by likes followed by date for default report management. Does not show resolved reports
          reportSnapshots = FirebaseFirestore.instance
              .collection('reports')
              .where('status', isNotEqualTo: ReportStatus.Resolved.toString())
              //.orderBy('likes', descending: true)
              //.orderBy('date', descending: true)
              .snapshots();
        }
      }
    } else {
      //on user profile
      if (status == ReportStatus.Submitted) {
        //only retrieve submitted reports
        reportSnapshots = FirebaseFirestore.instance
            .collection('reports')
            .where('userid', isEqualTo: userid)
            .where('status', isEqualTo: ReportStatus.Submitted.toString())
            //.orderBy('date', descending: true)
            .snapshots();
      } else if (status == ReportStatus.InProgress) {
        //only retrieve in progress reports
        reportSnapshots = FirebaseFirestore.instance
            .collection('reports')
            .where('userid', isEqualTo: userid)
            .where('status', isEqualTo: ReportStatus.InProgress.toString())
            //.orderBy('date', descending: true)
            .snapshots();
      } else if (status == ReportStatus.Resolved) {
        reportSnapshots = FirebaseFirestore.instance
            .collection('reports')
            .where('userid', isEqualTo: userid)
            .where('status', isEqualTo: ReportStatus.Resolved.toString())
            .orderBy('date', descending: true)
            .snapshots();
      } else {
        if (filter != 'All') {
          //filter by description type
          reportSnapshots = FirebaseFirestore.instance
              .collection('reports')
              .where('userid', isEqualTo: userid)
              .where('description', isEqualTo: filter)
              //.orderBy('likes', descending: true)
              //.orderBy('date', descending: true)
              .snapshots();
        } else if (location != null) {
          //find reports containing location name
          reportSnapshots = FirebaseFirestore.instance
              .collection('reports')
              .where('userid', isEqualTo: userid)
              .where('location keywords', arrayContains: location.split(' ')[0])
              //.orderBy('likes', descending: true)
              //.orderBy('date', descending: true)
              .snapshots();
        } else {
          //filter by user and order by date for default profile page
          reportSnapshots = FirebaseFirestore.instance
              .collection('reports')
              .where('userid', isEqualTo: userid)
              //.orderBy('date', descending: true)
              .snapshots();
        }
      }
    }

    return reportSnapshots
        .map((snapshot) {
          try {
            return snapshot.docs
                .where((doc) {
                  // If no search terms, don't filter
                  if (location == null) return true;

                  final keywords = List<String>.from(
                    doc['location keywords'] ?? [],
                  );

                  // every word typed must be in keywords
                  return location
                      .split(' ')
                      .every((term) => keywords.contains(term));
                })
                .map((doc) {
                  final data = doc.data();

                  return convertToReportModel(data, doc.id);
                })
                .toList()
              ..sort((report1, report2) {
                final report1score = calculatePriorityScore(report1);
                final report2score = calculatePriorityScore(report2);
                return report2score.compareTo(report1score); // descending
              });
          } catch (e, stack) {
            debugPrint('Error mapping reports: $e');
            debugPrint('$stack');
            return <ReportModel>[];
          }
        })
        .handleError((error) {
          debugPrint('Firestore stream error: $error');
        });
  }

  static ReportModel convertToReportModel(Map<String, dynamic> data, id) {
    return ReportModel(
      id: id,
      userId: data['userid'],
      latitude: data['latitude'],
      longitude: data['longitude'],
      date: data['date'].toDate(), // keep Timestamp
      description: data['description'] ?? '',
      longDescription: data['long description'] ?? '',
      photos: List<String>.from(data['photos'] ?? []),
      likes: data['likes'] ?? 0,
      dislikes: data['dislikes'] ?? 0,
      votes: Map<String, String>.from(data['votes'] ?? {}),
      locationText: data['location text'] ?? '',
      status: ReportStatusConverter.enumStringToReportStatus(data['status']),
      severity: data['severity'] ?? "No severity provided",
    );
  }

  static double calculatePriorityScore(ReportModel report) {
    final severity = int.tryParse(report.severity) ?? 0;
    final ageInDays = DateTime.now().difference(report.date).inDays.toDouble();
    final upVotes = report.likes.toDouble();
    final downVotes = report.dislikes.toDouble();

    //severity should dominate
    //add decay to age
    return (severity * 3) +
        (log(ageInDays + 1) * 0.5) +
        ((upVotes - downVotes) * 1.2);
  }

  static String getOppositeVote(String voteChoice) {
    if (voteChoice == 'likes') {
      return 'dislikes';
    } else {
      return 'likes';
    }
  }

  static Future<VoteResult> voteOnReportWithDifferentVote(
    ReportModel report,
    Map<String, String> votes,
    String voteChoice,
    String userid,
  ) async {
    votes[userid] = voteChoice;
    final oppositeVote = getOppositeVote(voteChoice);
    await FirebaseFirestore.instance
        .collection('reports')
        .doc(report.id)
        .update({
          voteChoice: FieldValue.increment(1),
          'votes': votes,
          oppositeVote: FieldValue.increment(-1),
        });
    return VoteResult(true, true);
  }

  static Future<VoteResult> voteOnReport(
    ReportModel report,
    Map<String, String> votes,
    String voteChoice,
    String userid,
  ) async {
    //not voted on this report before
    votes[userid] = voteChoice;
    await FirebaseFirestore.instance
        .collection('reports')
        .doc(report.id)
        .update({voteChoice: FieldValue.increment(1), 'votes': votes});

    return VoteResult(true, false);
  }

  static void updateStatus(ReportModel report, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('reports')
        .doc(report.id)
        .update({'status': newStatus});
  }

  static void deleteReport(String id) async {
    await FirebaseFirestore.instance.collection('reports').doc(id).delete();
  }

  static Future<DocumentReference<Map<String, dynamic>>> saveReport(
    Map<String, dynamic> report,
  ) async {
    return await FirebaseFirestore.instance.collection("reports").add(report);
  }

  static void updateSeverity(ReportModel report, String newSeverity) async {
    await FirebaseFirestore.instance
        .collection('reports')
        .doc(report.id)
        .update({'severity': newSeverity});
  }

  static void updatePhotos(ReportModel report, List<String> newPhotos) async {
    await FirebaseFirestore.instance
        .collection('reports')
        .doc(report.id)
        .update({'photos': FieldValue.arrayUnion(newPhotos)});
  }
}
