import 'package:flutter/material.dart';
import 'package:my_app/converters/report_status_converter.dart';
import 'package:my_app/enums/report_status.dart';
import 'package:my_app/helpers/handle_reports.dart';
import 'package:my_app/helpers/report_details.dart';
import 'package:my_app/pages/password_page.dart';
import '../layout/main_layout.dart';

class ReportManagementPage extends StatefulWidget {
  const ReportManagementPage({super.key});

  @override
  State<ReportManagementPage> createState() => _ReportManagementState();
}

class _ReportManagementState extends State<ReportManagementPage> {
  bool unlocked = false;
  String filter = "Likes";
  String? filterItem;
  bool isStatus = false;
  String? location;

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (!unlocked) {
      return PasswordPage(onSuccess: () => setState(() => unlocked = true));
    }

    return MainLayout(
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              "Manage reports",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(width: 20),
                Text("Filter: "),
                SizedBox(width: 5),
                DropdownButton<String>(
                  value: filter,
                  items: const [
                    DropdownMenuItem(
                      value: 'Submitted',
                      child: Text('Submitted'),
                    ),
                    DropdownMenuItem(
                      value: 'In Progress',
                      child: Text('In Progress'),
                    ),
                    DropdownMenuItem(
                      value: 'Resolved',
                      child: Text('Resolved'),
                    ),
                    DropdownMenuItem(value: 'Likes', child: Text('Likes')),
                    DropdownMenuItem(
                      value: 'Problem Type',
                      child: Text('Problem type'),
                    ),
                  ],
                  onChanged: (status) async {
                    String? problemItem;
                    if (status == 'Problem Type') {
                      String? problem = await showProblemTypePicker(context);
                      if (problem == null) {
                        problemItem = 'Likes';
                      } else {
                        problemItem = problem;
                      }
                      isStatus = false;
                    } else {
                      isStatus = true;
                      problemItem = status;
                    }
                    setState(() {
                      filter = status!;
                      location = null;
                      filterItem = problemItem;
                    });
                  },
                ),
                SizedBox(width: 15),
                Text('Search: '),
                SizedBox(width: 5),
                SizedBox(
                  height: 40,
                  width: 140,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 8),
                        const Icon(Icons.search),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            cursorColor: Colors.black,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.go,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 10,
                              ),
                              hintText: "Search...",
                            ),
                            onSubmitted: searchReportsInLocation,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: HandleReports.getAllReportsStream(
                  null,
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
                      return const Text(
                        "Cannot find any reports with that location",
                      );
                    }
                    if (filter == 'Likes') {
                      return const Text(
                        "There has not been any submitted reports yet",
                      );
                    }
                    return const Text(
                      "You have not got any reports under this filter",
                    );
                  }
                  return ListView.builder(
                    itemCount: userReports.length,
                    itemBuilder: (context, index) {
                      final reportData = userReports[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: getReportColour(reportData),
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
                            reportData['description'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 8),
                              Text(reportData['location text']),
                              SizedBox(height: 8),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'Reported on: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: reportData['date']
                                          .toDate()
                                          .toString()
                                          .split(' ')[0],
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
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          ReportStatusConverter.reportStatusToString(
                                            reportData['status'],
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          onTap: () => ReportDetails().showDetails(
                            context,
                            reportData,
                            true,
                            false,
                            onStatusChanged: () {
                              setState(() {});
                            },
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color getReportColour(Map<String, dynamic> report) {
    ReportStatus status = report['status'];
    if (status == ReportStatus.Submitted) {
      return Colors.red.shade200;
    } else if (status == ReportStatus.InProgress) {
      return Colors.amber.shade200;
    } else if (status == ReportStatus.Resolved) {
      return Colors.green.shade200;
    }
    return Colors.white;
  }

  Future<void> searchReportsInLocation(String query) async {
    setState(() {
      _searchController.clear();
      filter = "Likes";
      location = query;
    });
  }

  Future<String?> showProblemTypePicker(BuildContext context) async {
    List<String> possibleProblems = [
      "Blocked/overgrown footpath",
      "Damaged footpath",
      "Slippery footpath",
      "Locked gate",
      "Poor signage",
      "Poor visibility",
      "Safety hazard",
      "Accessibility issue, e,g, steep slope, narrow path, obstacles inaccessible for wheelchair users, etc.",
      "Flooding",
      "Temporary closure",
      "Farm/wildlife disruption",
    ];

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select problem to filter by"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...possibleProblems.map(
                  (problem) => TextButton(
                    onPressed: () {
                      Navigator.pop(context, problem); // return selected value
                    },
                    child: Text(problem),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
