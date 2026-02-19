import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:my_app/converters/report_status_converter.dart';
import 'package:my_app/enums/report_status.dart';

import '../services/image_viewer.dart';
import 'map_container.dart';

class ReportDetails {
  void showDetails(
    BuildContext context,
    Map<String, dynamic> report,
    bool isOnReportManagement,
    bool isOnUserProfile, {
    required VoidCallback onStatusChanged,
  }) {
    //open details of report
    final userid = FirebaseAuth.instance.currentUser!.uid;
    final votes = report['votes'];
    String? userVote = votes[userid];

    bool canDeleteReport =
        (isOnReportManagement && report['dislikes'] > 10) || isOnUserProfile;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Report details",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            report['description'] ?? '',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.thumb_up,
                                      color:
                                          (userVote != null &&
                                                  userVote == 'likes' ||
                                              isOnReportManagement)
                                          ? Colors.green[100]
                                          : Colors.green,
                                      size: 28,
                                    ),
                                    onPressed: () async {
                                      if (!isOnReportManagement) {
                                        final voteResult = await voteReport(
                                          report,
                                          'likes',
                                          context,
                                        );
                                        if (voteResult.successVote) {
                                          setModalState(() {
                                            report['likes']++;
                                            if (voteResult.decreaseOtherVote) {
                                              report['dislikes']--;
                                            }
                                            report['votes'][userid] = 'likes';
                                            userVote = 'likes';
                                          });
                                        }
                                      }
                                    },
                                  ),
                                  Text(report['likes'].toString()),
                                ],
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.thumb_down,
                                      color:
                                          (userVote != null &&
                                                  userVote == 'dislikes' ||
                                              isOnReportManagement)
                                          ? Colors.red[100]
                                          : Colors.red,
                                      size: 28,
                                    ),
                                    onPressed: () async {
                                      if (!isOnReportManagement) {
                                        final voteResult = await voteReport(
                                          report,
                                          'dislikes',
                                          context,
                                        );
                                        if (voteResult.successVote) {
                                          setModalState(() {
                                            report['dislikes']++;
                                            if (voteResult.decreaseOtherVote) {
                                              report['likes']--;
                                            }
                                            report['votes'][userid] =
                                                'dislikes';
                                            userVote = 'dislikes';
                                          });
                                        }
                                      }
                                    },
                                  ),
                                  Text(report['dislikes'].toString()),
                                ],
                              ),
                              if (isOnReportManagement) SizedBox(width: 20),
                              if (isOnReportManagement)
                                Column(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.access_time, size: 28),
                                      onPressed: () => showStatusChoices(
                                        context,
                                        report,
                                        setModalState,
                                        onStatusChanged,
                                      ),
                                    ),
                                    Text('Change \nStatus'),
                                  ],
                                ),
                              if (isOnReportManagement || isOnUserProfile)
                                SizedBox(width: 20),
                              if (isOnReportManagement || isOnUserProfile)
                                Column(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.delete, size: 28),
                                      color: canDeleteReport
                                          ? Colors.black
                                          : Colors.grey[400],
                                      onPressed: () {
                                        if (canDeleteReport) {
                                          deleteReport(
                                            report,
                                            context,
                                            onStatusChanged,
                                          );
                                        }
                                      },
                                    ),
                                    Text(
                                      'Delete \nreport',
                                      style: TextStyle(
                                        color: canDeleteReport
                                            ? Colors.black
                                            : Colors.grey[400],
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(report['location text']),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.3,
                            width: double.infinity,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: MapContainer(
                                showReportsToggle: false,
                                showSearchBar: false,
                                showRecentre: false,
                                isShowingReportDetails: true,
                                initialLocation: LatLng(
                                  report['latitude'],
                                  report['longitude'],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            (report['long description'] == null ||
                                    report['long description']
                                        .toString()
                                        .trim()
                                        .isEmpty)
                                ? '(No further details provided)'
                                : report['long description'],
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Reported on: ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: report['date']
                                      .toDate()
                                      .toString()
                                      .split(' ')[0],
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Status: ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      ReportStatusConverter.reportStatusToString(
                                        report['status'],
                                      ),
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Photos: ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          report['photos'] != null &&
                                  report['photos']!.isNotEmpty
                              ? SizedBox(
                                  height: 120,
                                  child: GridView.builder(
                                    itemCount: report['photos']?.length ?? 0,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          crossAxisSpacing: 4,
                                          mainAxisSpacing: 4,
                                        ),
                                    itemBuilder: (context, index) {
                                      final imageUrl = report['photos'][index];
                                      return GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) => ImageGalleryViewer(
                                              images: List<String>.from(
                                                report['photos'],
                                              ),
                                              initialIndex: index,
                                            ),
                                          );
                                        },
                                        child: Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Text(
                                  "No images added",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static String getOppositeVote(String voteChoice) {
    if (voteChoice == 'likes') {
      return 'dislikes';
    } else {
      return 'likes';
    }
  }

  static Future<VoteResult> voteReport(
    Map<String, dynamic> report,
    String voteChoice,
    BuildContext context,
  ) async {
    final userid = FirebaseAuth.instance.currentUser!.uid;

    final votes = report['votes'];
    if (votes.containsKey(userid)) {
      //already voted
      if (votes[userid] == voteChoice) {
        //voted with same vote as before
        return VoteResult(false, false);
      } else {
        //voted with different vote to before
        final replaceVote = await checkUserWantsToChangeVote(context);
        if (!replaceVote) {
          return VoteResult(false, false);
        }
        votes[userid] = voteChoice;
        final oppositeVote = getOppositeVote(voteChoice);
        await FirebaseFirestore.instance
            .collection('reports')
            .doc(report['id'])
            .update({
              voteChoice: FieldValue.increment(1),
              'votes': votes,
              oppositeVote: FieldValue.increment(-1),
            });
        return VoteResult(true, true);
      }
    }

    //not voted on this report before
    votes[userid] = voteChoice;
    await FirebaseFirestore.instance
        .collection('reports')
        .doc(report['id'])
        .update({voteChoice: FieldValue.increment(1), 'votes': votes});

    return VoteResult(true, false);
  }

  static Future<bool> checkUserWantsToChangeVote(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Change your vote"),
            content: const Text(
              "You have already voted on this report. Do you want to change your vote?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("No, cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Yes, change it"),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> showStatusChoices(
    BuildContext context,
    Map<String, dynamic> report,
    void Function(void Function()) setModalState,
    VoidCallback onStatusChanged,
  ) async {
    final result = await showDialog<ReportStatus>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          insetPadding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 150, // minimum width
              maxWidth: 250, // maximum width
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Change Report Status",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Select the new status:",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () =>
                        Navigator.pop(context, ReportStatus.Submitted),
                    child: const Text(
                      "Submitted",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.pop(context, ReportStatus.InProgress),
                    child: const Text(
                      "In Progress",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.pop(context, ReportStatus.Resolved),
                    child: const Text(
                      "Resolved",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const Divider(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context, null),
                    child: const Text("Cancel", style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (result != null) {
      setModalState(() {
        report['status'] = result;
      });
      await FirebaseFirestore.instance
          .collection('reports')
          .doc(report['id'])
          .update({'status': result.toString()});
      onStatusChanged();
    }
  }

  void deleteReport(
    Map<String, dynamic> report,
    BuildContext context,
    VoidCallback onStatusChanged,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text("Are you sure you want to delete this report?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('reports')
          .doc(report['id'])
          .delete();

      Navigator.pop(context, null);
      onStatusChanged();
    }
  }
}

class VoteResult {
  final bool successVote;
  final bool decreaseOtherVote;

  VoteResult(this.successVote, this.decreaseOtherVote);
}
