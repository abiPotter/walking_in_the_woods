import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/helpers/handle_reports.dart';

import '../layout/main_layout.dart';
import '../helpers/report_details.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userid = FirebaseAuth.instance.currentUser!.uid;

    return MainLayout(
        child: Center(
            child: Column(children: [
      const SizedBox(height: 16),
      const Text("Your reports",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: HandleReports.getAllReportsStream(userid),
        builder: ((context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }

          final userReports = snapshot.data!.toList();

          if (userReports.isEmpty) {
            return const Text("You have not submitted any reports yet");
          }

          return ListView.builder(
            itemCount: userReports.length,
            itemBuilder: (context, index) {
              final reportData = userReports[index];
              return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.blueAccent),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        )
                      ]),
                  child: ListTile(
                    title: Text(reportData['description'],
                        style: TextStyle(fontWeight: FontWeight.bold)),
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
                                style: TextStyle(fontWeight: FontWeight.bold),
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
                      ],
                    ),
                    onTap: () =>
                        ReportDetails().showDetails(context, reportData),
                  ));
            },
          );
        }),
      ))
    ])));
  }
}
