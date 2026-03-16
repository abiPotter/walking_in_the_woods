import 'package:flutter/material.dart';
import 'package:roam_and_report/converters/report_status_converter.dart';
import 'package:roam_and_report/models/report_model.dart';
import 'package:roam_and_report/services/report_provider.dart';
import 'package:roam_and_report/widgets/report_details.dart';

class ReportsList extends StatelessWidget {
  final String? userid;
  final bool isStatus;
  final String? filterItem;
  final String? location;
  final bool isOnReportManagement;
  final bool isOnUserProfile;

  const ReportsList({
    super.key,
    required this.userid,
    this.isStatus = false,
    this.filterItem,
    this.location,
    this.isOnReportManagement = false,
    this.isOnUserProfile = false,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ReportModel>>(
      stream: ReportProvider().getSpecificReports(
        userid,
        isStatus,
        filterItem,
        location,
      ),
      builder: ((context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final userReports = snapshot.data ?? [];

        if (userReports.isEmpty) {
          if (location != null) {
            return const Text("Cannot find any reports with that location");
          }
          if (filterItem == 'Date') {
            return const Text("You have not submitted any reports yet");
          }
          return const Text("You have not got any reports under this filter");
        }

        return ListView.builder(
          itemCount: userReports.length,
          itemBuilder: (context, index) {
            final reportData = userReports[index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: ReportProvider.getReportColour(reportData),
                border: Border.all(color: Colors.blueAccent),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                title: Text(
                  reportData.description,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    Text(reportData.locationText),
                    SizedBox(height: 8),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Reported on: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: reportData.date.toString().split(' ')[0],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Status: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: ReportStatusConverter.reportStatusToString(
                              reportData.status,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => ReportDetails(
                    report: reportData,
                    isOnReportManagement: isOnReportManagement,
                    isOnUserProfile: isOnUserProfile,
                    onStatusChanged: () {},
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
