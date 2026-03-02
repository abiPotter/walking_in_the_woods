import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:my_app/converters/report_status_converter.dart';
import 'package:my_app/enums/report_status.dart';
import 'package:my_app/helpers/report_details.dart';

class HandleReports {
  static Stream<List<Map<String, dynamic>>> getAllReportsStream(
    String? userid,
    bool isStatus,
    String? filter,
    String? location,
  ) {
    ReportStatus? status;
    if (isStatus) {
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
            .orderBy('likes', descending: true)
            .orderBy('date', descending: true)
            .snapshots();
      } else if (status == ReportStatus.InProgress) {
        //only retrieve in progress reports
        reportSnapshots = FirebaseFirestore.instance
            .collection('reports')
            .where('status', isEqualTo: ReportStatus.InProgress.toString())
            .orderBy('likes', descending: true)
            .orderBy('date', descending: true)
            .snapshots();
      } else if (status == ReportStatus.Resolved) {
        reportSnapshots = FirebaseFirestore.instance
            .collection('reports')
            .where('status', isEqualTo: ReportStatus.Resolved.toString())
            .orderBy('likes', descending: true)
            .orderBy('date', descending: true)
            .snapshots();
      } else {
        if (filter != 'Likes' && filter != 'Date') {
          //filter by description type
          reportSnapshots = FirebaseFirestore.instance
              .collection('reports')
              .where('description', isEqualTo: filter)
              .orderBy('likes', descending: true)
              .orderBy('date', descending: true)
              .snapshots();
        } else if (location != null) {
          //find reports containing location name
          reportSnapshots = FirebaseFirestore.instance
              .collection('reports')
              .where('location keywords', arrayContains: location.split(' ')[0])
              .orderBy('likes', descending: true)
              .orderBy('date', descending: true)
              .snapshots();
        } else {
          //order by likes followed by date for default report management. Does not show resolved reports
          reportSnapshots = FirebaseFirestore.instance
              .collection('reports')
              .where('status', isNotEqualTo: ReportStatus.Resolved.toString())
              .orderBy('likes', descending: true)
              .orderBy('date', descending: true)
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
            .orderBy('date', descending: true)
            .snapshots();
      } else if (status == ReportStatus.InProgress) {
        //only retrieve in progress reports
        reportSnapshots = FirebaseFirestore.instance
            .collection('reports')
            .where('userid', isEqualTo: userid)
            .where('status', isEqualTo: ReportStatus.InProgress.toString())
            .orderBy('date', descending: true)
            .snapshots();
      } else if (status == ReportStatus.Resolved) {
        reportSnapshots = FirebaseFirestore.instance
            .collection('reports')
            .where('userid', isEqualTo: userid)
            .where('status', isEqualTo: ReportStatus.Resolved.toString())
            .orderBy('date', descending: true)
            .snapshots();
      } else {
        if (filter != 'Date') {
          //filter by description type
          reportSnapshots = FirebaseFirestore.instance
              .collection('reports')
              .where('userid', isEqualTo: userid)
              .where('description', isEqualTo: filter)
              .orderBy('likes', descending: true)
              .orderBy('date', descending: true)
              .snapshots();
        } else if (location != null) {
          //find reports containing location name
          reportSnapshots = FirebaseFirestore.instance
              .collection('reports')
              .where('userid', isEqualTo: userid)
              .where('location keywords', arrayContains: location.split(' ')[0])
              .orderBy('likes', descending: true)
              .orderBy('date', descending: true)
              .snapshots();
        } else {
          //filter by user and order by date for default profile page
          reportSnapshots = FirebaseFirestore.instance
              .collection('reports')
              .where('userid', isEqualTo: userid)
              .orderBy('date', descending: true)
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

                  return {
                    'id': doc.id,
                    'userid': data['userid'],
                    'latitude': data['latitude'],
                    'longitude': data['longitude'],
                    'date': data['date'], // keep Timestamp
                    'description': data['description'] ?? '',
                    'long description': data['long description'] ?? '',
                    'photos': data['photos'] ?? [],
                    'likes': data['likes'] ?? 0,
                    'dislikes': data['dislikes'] ?? 0,
                    'votes': Map<String, dynamic>.from(data['votes'] ?? {}),
                    'location text': data['location text'] ?? '',
                    'status': ReportStatusConverter.enumStringToReportStatus(
                      data['status'],
                    ),
                  };
                })
                .toList();
          } catch (e, stack) {
            debugPrint('Error mapping reports: $e');
            debugPrint('$stack');
            return <Map<String, dynamic>>[];
          }
        })
        .handleError((error) {
          debugPrint('Firestore stream error: $error');
        });
  }

  static Stream<List<Marker>> getReportMarkers(BuildContext context) {
    return getAllReportsStream(null, false, 'Date', null).map((reports) {
      return reports.map((report) {
        final lat = report['latitude'];
        final lng = report['longitude'];

        return Marker(
          width: 40,
          height: 40,
          point: LatLng(lat, lng),
          child: GestureDetector(
            onTap: () => ReportDetails().showDetails(
              context,
              report,
              false,
              false,
              onStatusChanged: () {},
            ),
            child: const Icon(
              Icons.location_on,
              color: Colors.purple,
              size: 35,
            ),
          ),
        );
      }).toList();
    });
  }
}
