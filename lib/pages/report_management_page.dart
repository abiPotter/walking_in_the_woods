import 'package:flutter/material.dart';
import 'package:roam_and_report/pages/password_page.dart';
import 'package:roam_and_report/widgets/reports_list.dart';
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
              child: ReportsList(
                userid: null,
                isStatus: isStatus,
                filterItem: filterItem,
                location: location,
                isOnReportManagement: true,
              ),
            ),
          ],
        ),
      ),
    );
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
