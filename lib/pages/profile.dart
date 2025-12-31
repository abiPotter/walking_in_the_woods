import 'package:flutter/material.dart';

import '../layout/main_layout.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
        child: Container(
            color: Colors.pink,
            child: const Center(
              child: Text(
                'Profile page',
                style: TextStyle(fontSize: 20),
              ),
            )));
  }
}
