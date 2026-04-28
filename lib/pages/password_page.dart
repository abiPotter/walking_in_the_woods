import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:roam_and_report/layout/main_layout.dart';

class PasswordPage extends StatefulWidget {
  final VoidCallback onSuccess;

  const PasswordPage({required this.onSuccess, super.key});

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final TextEditingController controller = TextEditingController();
  bool incorrectPassword = false;
  //admin password stored in environment variable
  final String? adminPassword = kIsWeb
      ? const String.fromEnvironment('ADMIN_PASSWORD')
      : dotenv.env['ADMIN_PASSWORD'];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Report Management",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              "(Only authorized administrators can access this section)",
              style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              "Enter the admin password to review and update reports:",
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(height: 10),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                errorText: incorrectPassword ? "Incorrect password" : null,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: incorrectPassword ? Colors.red : Colors.grey,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: incorrectPassword ? Colors.red : Colors.blue,
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text == adminPassword) {
                  widget.onSuccess(); // telling parent to unlock
                } else {
                  setState(() {
                    incorrectPassword = true;
                  });
                }
              },
              child: Text("Unlock"),
            ),
          ],
        ),
      ),
    );
  }
}
