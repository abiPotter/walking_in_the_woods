import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HandleReports {
  static final CollectionReference reportsRef =
      FirebaseFirestore.instance.collection('reports');

  static Future<List<Map<String, dynamic>>> getAllReports() async {
    try {
      QuerySnapshot querySnapshot = await reportsRef.get();
      List<Map<String, dynamic>> allReports = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'latitude': data['latitute'], // note the field name as saved
          'longitude': data['longitude'],
          'date': (data['date'] as Timestamp).toDate(),
          'description': data['description'],
          'longDescription': data['long description'],
          'photos': data['photos'],
          'likes': data['likes'],
          'dislikes': data['dislikes']
        };
      }).toList();
      return allReports;
    } catch (e) {
      debugPrint('Error fetching reports: $e');
      return [];
    }
  }

  static Future<List<Marker>> getReportMarkers(BuildContext context) async {
    final reports = await getAllReports();
    final markers = reports
        .map((report) {
          final lat = report['latitude'] as double?;
          final lng = report['longitude'] as double?;
          if (lat == null || lng == null) return null;

          return Marker(
            width: 40,
            height: 40,
            point: LatLng(lat, lng),
            child: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                    context: context,
                    builder: (_) {
                      return StatefulBuilder(builder: (context, setModalState) {
                        return Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  16, 48, 16, 16), // top:48,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(report['description'] ?? '',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  Text(
                                      (report['longDescription'] == null ||
                                              report['longDescription']
                                                  .toString()
                                                  .trim()
                                                  .isEmpty)
                                          ? '(No further details provided)'
                                          : report['longDescription'],
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic)),
                                  const SizedBox(height: 8),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        const TextSpan(
                                          text: 'Reported on: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                          text: report['date']
                                              .toString()
                                              .split(' ')[0],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Photos: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 5),
                                  report['photos'] != null &&
                                          report['photos']!.isNotEmpty
                                      ? Expanded(
                                          child: SizedBox(
                                            height: 80,
                                            child: GridView.builder(
                                              itemCount:
                                                  report['photos']?.length ?? 0,
                                              gridDelegate:
                                                  SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 3,
                                                crossAxisSpacing: 4,
                                                mainAxisSpacing: 4,
                                              ),
                                              itemBuilder: (context, index) {
                                                return Image.network(
                                                  report['photos'][index],
                                                  fit: BoxFit.cover,
                                                );
                                              },
                                            ),
                                          ),
                                        )
                                      : Text("No images added"),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Row(children: [
                                Column(children: [
                                  IconButton(
                                    icon: const Icon(Icons.thumb_up,
                                        color: Colors.green, size: 28),
                                    onPressed: () async {
                                      setModalState(() {
                                        report['likes']++;
                                      });
                                      await likeReport(report);
                                    },
                                  ),
                                  Text(report['likes'].toString())
                                ]),
                                Column(children: [
                                  IconButton(
                                    icon: const Icon(Icons.thumb_down,
                                        color: Colors.red, size: 28),
                                    onPressed: () async {
                                      setModalState(() {
                                        report['dislikes']++;
                                      });
                                      await dislikeReport(report);
                                    },
                                  ),
                                  Text(report['dislikes'].toString()),
                                ]),
                              ]),
                            ),
                          ],
                        );
                      });
                    });
              },
              child:
                  const Icon(Icons.location_on, color: Colors.purple, size: 35),
            ),
          );
        })
        .whereType<Marker>()
        .toList();

    return markers;
  }

  static Future<void> likeReport(Map<String, dynamic> report) async {
    await FirebaseFirestore.instance
        .collection('reports')
        .doc(report['id']) // 👈 use the document ID
        .update({
      'likes': FieldValue.increment(1),
    });
  }

  static Future<void> dislikeReport(Map<String, dynamic> report) async {
    await FirebaseFirestore.instance
        .collection('reports')
        .doc(report['id']) // 👈 use the document ID
        .update({
      'dislikes': FieldValue.increment(1),
    });
  }
}
