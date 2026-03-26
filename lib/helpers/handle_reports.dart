import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:roam_and_report/converters/report_status_converter.dart';
import 'package:roam_and_report/enums/report_status.dart';
import 'package:roam_and_report/models/graphs/report_dates.dart';
import 'package:roam_and_report/models/graphs/report_descriptions.dart';
import 'package:roam_and_report/models/graphs/report_severities.dart';
import 'package:roam_and_report/models/report_model.dart';

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
        if (filter != 'Likes' && filter != 'All') {
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
              .where('status', isNotEqualTo: ReportStatus.Resolved.toString())
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

  Future<List<ReportDates>> getReportsLast30Days() async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: 29)); //include todays date

    final snapshot = await FirebaseFirestore.instance
        .collection('reports')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .get();

    // Map to store counts per day
    Map<DateTime, int> counts = {};

    for (var doc in snapshot.docs) {
      final timestamp = doc['date'] as Timestamp;
      final date = timestamp.toDate();

      // Normalize to just year/month/day (remove time)
      final day = DateTime(date.year, date.month, date.day);

      counts[day] = (counts[day] ?? 0) + 1;
    }

    // Build full 30-day list (including empty days)
    List<ReportDates> result = [];

    for (int i = 0; i < 30; i++) {
      final day = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
      ).add(Duration(days: i));

      result.add(ReportDates(date: day, totalReports: counts[day] ?? 0));
    }

    return result;
  }

  Future<List<ReportSeverities>> getReportSeverityCounts() async {
    //only getting for last 30 days
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: 29)); //include todays date

    final snapshot = await FirebaseFirestore.instance
        .collection('reports')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .get();

    // Map to store counts per severity
    Map<int, int> counts = {};
    for (var doc in snapshot.docs) {
      if (doc['status'] == ReportStatus.Resolved.toString()) continue;

      final data = doc.data();
      String reportSeverity = "0";
      if (data.containsKey('severity')) {
        reportSeverity = doc['severity'];
      }
      final severity = int.tryParse(reportSeverity) ?? 0;
      counts[severity] = (counts[severity] ?? 0) + 1;
    }

    // Build full severity list
    List<ReportSeverities> result = [];
    for (int i = 1; i <= 10; i++) {
      result.add(ReportSeverities(severity: i, totalReports: counts[i] ?? 0));
    }

    return result;
  }

  Future<List<ReportDescriptions>> getReportDescriptions() async {
    //only getting for last 30 days
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: 29)); //include todays date

    final snapshot = await FirebaseFirestore.instance
        .collection('reports')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .get();

    // Map to store counts per description
    Map<String, int> counts = {};
    for (var doc in snapshot.docs) {
      String description = doc['description'];
      if (description ==
          "Accessibility issue, e,g, steep slope, narrow path, obstacles inaccessible for wheelchair users, etc.") {
        description = "Accessibility issue";
      }
      counts[description] = (counts[description] ?? 0) + 1;
    }

    List<String> possibleProblems = [
      "Blocked/overgrown footpath",
      "Damaged footpath",
      "Slippery footpath",
      "Muddy/boggy",
      "Locked gate",
      "Poor signage",
      "Poor visibility",
      "Safety hazard",
      "Accessibility issue",
      "Flooding",
      "Temporary closure",
      "Farm/wildlife disruption",
      "Other",
    ];

    // Build full description list
    List<ReportDescriptions> result = [];
    for (int i = 0; i < 12; i++) {
      result.add(
        ReportDescriptions(
          description: possibleProblems[i],
          totalReports: counts[possibleProblems[i]] ?? 0,
        ),
      );
    }

    return result;
  }

  static double calculatePriorityScore(ReportModel report) {
    final severity = int.tryParse(report.severity) ?? 0;
    final ageInDays = DateTime.now().difference(report.date).inDays.toDouble();
    final upVotes = report.likes.toDouble();
    final downVotes = report.dislikes.toDouble();

    //severity should dominate
    //add decay to age
    return (severity * 4) +
        (log(ageInDays + 1) * 0.5) +
        ((upVotes - downVotes) * 1.2);
  }

  static void voteOnReport(
    ReportModel report,
    Map<String, String> votes,
    String voteChoice,
    String userid,
  ) async {
    votes[userid] = voteChoice;
    await FirebaseFirestore.instance
        .collection('reports')
        .doc(report.id)
        .update({voteChoice: FieldValue.increment(1), 'votes': votes});
  }

  static String getOppositeVote(String voteChoice) {
    if (voteChoice == 'likes') {
      return 'dislikes';
    } else {
      return 'likes';
    }
  }

  static void voteOnReportWithDifferentVote(
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
  }

  static void removeVoteOnReport(
    ReportModel report,
    Map<String, String> votes,
    String currentVote,
    String userid,
  ) async {
    //removing vote
    votes.remove(userid);
    await FirebaseFirestore.instance
        .collection('reports')
        .doc(report.id)
        .update({currentVote: FieldValue.increment(-1), 'votes': votes});
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
