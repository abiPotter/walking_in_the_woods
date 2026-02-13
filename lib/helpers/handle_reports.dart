import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:my_app/helpers/report_details.dart';

class HandleReports {
  static Stream<List<Map<String, dynamic>>> getAllReportsStream(
      String? userid) {
    Stream<QuerySnapshot<Map<String, dynamic>>> reportSnapshots;
    if (userid == null) {
      reportSnapshots =
          FirebaseFirestore.instance.collection('reports').snapshots();
    } else {
      reportSnapshots = FirebaseFirestore.instance
          .collection('reports')
          .where('userid', isEqualTo: userid)
          .orderBy('date', descending: true)
          .snapshots();
    }

    return reportSnapshots.map((snapshot) {
      try {
        return snapshot.docs.map((doc) {
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
            'status': data['status']
          };
        }).toList();
      } catch (e, stack) {
        debugPrint('Error mapping reports: $e');
        debugPrint('$stack');
        return <Map<String, dynamic>>[];
      }
    }).handleError((error) {
      debugPrint('Firestore stream error: $error');
    });
  }

  static Stream<List<Marker>> getReportMarkers(BuildContext context) {
    return getAllReportsStream(null).map((reports) {
      return reports.map((report) {
        final lat = report['latitude'];
        final lng = report['longitude'];

        return Marker(
          width: 40,
          height: 40,
          point: LatLng(lat, lng),
          child: GestureDetector(
            onTap: () => ReportDetails().showDetails(context, report),
            child:
                const Icon(Icons.location_on, color: Colors.purple, size: 35),
          ),
        );
      }).toList();
    });
  }
}
