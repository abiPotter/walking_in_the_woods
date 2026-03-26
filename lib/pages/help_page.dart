import 'package:flutter/material.dart';
import 'package:roam_and_report/layout/main_layout.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "About and Help",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  "Learn how to use the app to view, create, and interact with reports.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),

              HelpSection(
                title: "Creating a Report",
                icon: Icons.add_location_alt,
                children: const [
                  BulletPoint(
                    icon: Icons.touch_app,
                    text:
                        "Long press on the map to select a location (shows a purple pin), or open the report page from the menu.",
                  ),
                  BulletPoint(
                    icon: Icons.edit,
                    text:
                        "Enter details such as description, severity, date found, and optional photos.",
                  ),
                  BulletPoint(
                    icon: Icons.upload,
                    text:
                        "Submit your report to add it to the map and your profile.",
                  ),
                ],
              ),

              HelpSection(
                title: "Viewing Reports",
                icon: Icons.visibility,
                children: const [
                  BulletPoint(
                    icon: Icons.map,
                    text:
                        "Tap a map marker to view detailed report information.",
                  ),
                  BulletPoint(
                    icon: Icons.info,
                    text:
                        "See description, severity, and votes from other users.",
                  ),
                  BulletPoint(
                    icon: Icons.person,
                    text:
                        "Access your reports anytime through your user profile.",
                  ),
                  BulletPoint(
                    icon: Icons.access_time,
                    text:
                        "Admin users can change the status of your report (Submitted, In Progress, Resolved).",
                  ),
                ],
              ),

              HelpSection(
                title: "Voting on Reports",
                icon: Icons.how_to_vote,
                children: const [
                  BulletPoint(
                    icon: Icons.thumb_up,
                    text:
                        "Tap thumbs up or down to vote while viewing a report.",
                  ),
                  BulletPoint(
                    icon: Icons.change_circle,
                    text: "Tap your vote again to change or remove it.",
                  ),
                  BulletPoint(
                    icon: Icons.person_outline,
                    text: "Each user can only have one active vote per report.",
                  ),
                ],
              ),

              HelpSection(
                title: "User Profile",
                icon: Icons.person,
                children: const [
                  BulletPoint(
                    icon: Icons.list_alt,
                    text: "View all reports you have created in one place.",
                  ),
                  BulletPoint(
                    icon: Icons.search,
                    text: "Filter and search through your reports.",
                  ),
                  BulletPoint(
                    icon: Icons.warning_amber,
                    text:
                        "Note: Using anonymous accounts means data may be lost when the app is restarted.",
                  ),
                ],
              ),

              HelpSection(
                title: "Search and Navigation",
                icon: Icons.search,
                children: const [
                  BulletPoint(
                    icon: Icons.map,
                    text: "Explore different areas using the interactive map.",
                  ),
                  BulletPoint(
                    icon: Icons.place,
                    text:
                        "Browse reports submitted by other users nearby. These reports are colour-coded by severity level.",
                  ),
                  BulletPoint(
                    icon: Icons.layers,
                    text: "Search for locations and switch between map styles.",
                  ),
                ],
              ),
              Divider(color: Colors.black, thickness: 3),
              HelpSection(
                title: "Prototype Notice",
                icon: Icons.warning_amber_rounded,
                children: const [
                  BulletPoint(
                    icon: Icons.info_outline,
                    text:
                        "This app is currently a prototype. Features may change over time.",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HelpSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const HelpSection({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class BulletPoint extends StatelessWidget {
  final String text;
  final IconData icon;

  const BulletPoint({super.key, required this.text, this.icon = Icons.circle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.blueAccent),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
