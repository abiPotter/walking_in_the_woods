import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:roam_and_report/converters/report_status_converter.dart';
import 'package:roam_and_report/enums/report_status.dart';
import 'package:roam_and_report/helpers/local_council_info.dart';
import 'package:roam_and_report/models/report_model.dart';
import 'package:roam_and_report/models/vote_result.dart';
import 'package:roam_and_report/services/report_provider.dart';

import '../services/image_viewer.dart';
import 'map_container.dart';

class ReportDetails extends StatefulWidget {
  final ReportModel report;
  final bool isOnReportManagement;
  final bool isOnUserProfile;
  final VoidCallback onStatusChanged;

  const ReportDetails({
    super.key,
    required this.report,
    this.isOnReportManagement = false,
    this.isOnUserProfile = false,
    required this.onStatusChanged,
  });

  @override
  State<ReportDetails> createState() => _ReportDetailsState();
}

class _ReportDetailsState extends State<ReportDetails> {
  //late int likes;
  //late int dislikes;
  //late Map<String, String> votes;
  late String? userVote;

  late ReportModel report;
  late bool isOnReportManagement;
  late bool isOnUserProfile;
  late VoidCallback onStatusChanged;

  @override
  void initState() {
    super.initState();

    report = widget.report;

    final uid = FirebaseAuth.instance.currentUser!.uid;
    userVote = report.votes[uid];

    isOnReportManagement = widget.isOnReportManagement;
    isOnUserProfile = widget.isOnUserProfile;
    onStatusChanged = widget.onStatusChanged;
  }

  @override
  Widget build(BuildContext context) {
    bool canDeleteReport =
        (isOnReportManagement && report.dislikes > 10) || isOnUserProfile;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                    report.description,
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
                                  (userVote != null && userVote == 'likes' ||
                                      isOnReportManagement)
                                  ? Colors.green[100]
                                  : Colors.green,
                              size: 28,
                            ),
                            onPressed: () async {
                              if (!isOnReportManagement) {
                                await voteReport(report, 'likes', context);
                              }
                            },
                          ),
                          Text(report.likes.toString()),
                        ],
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.thumb_down,
                              color:
                                  (userVote != null && userVote == 'dislikes' ||
                                      isOnReportManagement)
                                  ? Colors.red[100]
                                  : Colors.red,
                              size: 28,
                            ),
                            onPressed: () async {
                              if (!isOnReportManagement) {
                                await voteReport(report, 'dislikes', context);
                              }
                            },
                          ),
                          Text(report.dislikes.toString()),
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
                  Text(report.locationText),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3,
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: MapContainer(
                        showReportsToggle: false,
                        showSearchBar: false,
                        showRecentre: false,
                        isShowingReportDetails: true,
                        initialLocation: LatLng(
                          report.latitude,
                          report.longitude,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    (report.longDescription?.trim().isEmpty ?? true)
                        ? '(No further details provided)'
                        : report.longDescription!,
                    style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
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
                          text: report.date.toString().split(' ')[0],
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
                          text: ReportStatusConverter.reportStatusToString(
                            report.status,
                          ),
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Photos: ',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  report.photos.isNotEmpty
                      ? SizedBox(
                          height: 120,
                          child: GridView.builder(
                            itemCount: report.photos.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 4,
                                  mainAxisSpacing: 4,
                                ),
                            itemBuilder: (context, index) {
                              final imageUrl = report.photos[index];
                              return GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => ImageGalleryViewer(
                                      images: List<String>.from(report.photos),
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
                  if (isOnReportManagement || isOnUserProfile)
                    SizedBox(height: 8),
                  if (isOnReportManagement || isOnUserProfile)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.apartment),
                      label: const Text("Local Council Information"),
                      onPressed: () => showLocalCouncilInfo(
                        context,
                        LatLng(report.latitude, report.longitude),
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
  }

  Future<void> voteReport(
    ReportModel report,
    String voteChoice,
    BuildContext context,
  ) async {
    final userid = FirebaseAuth.instance.currentUser!.uid;

    final voteResult = await ReportProvider().voteReport(
      report,
      voteChoice,
      userid,
    );

    if (voteResult.needsConfirmation) {
      final replaceVote = await checkUserWantsToChangeVote(context);
      if (!replaceVote) {
        return;
      }

      final confirmedResult = await ReportProvider()
          .voteOnReportWithDifferentVote(
            report,
            Map.from(report.votes),
            voteChoice,
            userid,
          );
      if (confirmedResult.successVote) _updateVote(confirmedResult, voteChoice);
      return;
    }
    if (voteResult.successVote) {
      _updateVote(voteResult, voteChoice);
    }
  }

  void _updateVote(VoteResult result, String voteChoice) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    setState(() {
      report = report.copyWith(
        likes: voteChoice == 'likes'
            ? report.likes + 1
            : (result.decreaseOtherVote ? report.likes - 1 : report.likes),
        dislikes: voteChoice == 'dislikes'
            ? report.dislikes + 1
            : (result.decreaseOtherVote
                  ? report.dislikes - 1
                  : report.dislikes),
        votes: {...report.votes, userId: voteChoice},
      );
      userVote = voteChoice;
    });
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
    ReportModel report,
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
      setState(() {
        report.status = result;
      });

      ReportProvider.updateReportStatus(report, result.toString());

      onStatusChanged();
    }
  }

  void deleteReport(
    ReportModel report,
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
      ReportProvider.deleteReport(report.id);

      Navigator.pop(context, null);
      onStatusChanged();
    }
  }

  void showLocalCouncilInfo(BuildContext context, LatLng location) async {
    await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Council information',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  LocalCouncilInfo().showLocalCouncilInfo(location),
                ],
              ),
            ),

            // Close button in true top-right
            Positioned(
              right: 0,
              top: 0,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
