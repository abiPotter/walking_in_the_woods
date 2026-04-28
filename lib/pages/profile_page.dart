import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:roam_and_report/helpers/states/admin_state.dart';
import 'package:roam_and_report/widgets/reports_list.dart';
import 'package:roam_and_report/layout/main_layout.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final userid = FirebaseAuth.instance.currentUser!.uid;

  String filter = "All";
  String? filterItem = "All";
  bool isStatus = false;
  String? location;

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isAdmin = Provider.of<AdminState>(context).isAdmin;

    return MainLayout(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(4),
          child: Column(
            children: [
              const SizedBox(height: 8),
              const Text(
                "Your reports",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (!isAdmin)
                const Text(
                  "You are currently using an anonymous account.\n"
                  "Reports you submit may not appear in your list if you reinstall the app or clear data.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  SizedBox(width: 12),
                  Text("Filter: "),
                  SizedBox(width: 5),
                  DropdownButton<String>(
                    value: filter,
                    isDense: true,
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
                      DropdownMenuItem(value: 'All', child: Text('All Active')),
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
                          problemItem = 'All';
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
                  SizedBox(width: 12),
                  Text('Search: '),
                  SizedBox(width: 5),
                  Expanded(
                    child: SizedBox(
                      height: 38,
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
                  ),

                  const SizedBox(width: 10),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ReportsList(
                  userid: userid,
                  isStatus: isStatus,
                  filterItem: filterItem,
                  location: location,
                  isOnUserProfile: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> searchReportsInLocation(String query) async {
    setState(() {
      _searchController.clear();
      filter = "All";
      location = query;
    });
  }

  Future<String?> showProblemTypePicker(BuildContext context) async {
    List<String> possibleProblems = [
      "Blocked/overgrown footpath",
      "Damaged footpath",
      "Slippery footpath",
      "Muddy/boggy",
      "Locked gate",
      "Poor signage",
      "Poor visibility",
      "Safety hazard",
      "Accessibility issue, e.g, steep slope, narrow path, obstacles inaccessible for wheelchair users, etc.",
      "Flooding",
      "Temporary closure",
      "Farm/wildlife disruption",
      "Other",
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
