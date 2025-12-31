import 'package:flutter/material.dart';
import '../layout/main_layout.dart';

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
        child: Container(
            color: Colors.red,
            child: const Center(
              child: Text(
                'Second page',
                style: TextStyle(fontSize: 20),
              ),
            )));
  }
}
