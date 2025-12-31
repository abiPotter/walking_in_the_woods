import 'package:flutter/material.dart';
import '../layout/main_layout.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
        child: Container(
            color: Colors.purple,
            child: const Center(
              child: Text(
                'First page',
                style: TextStyle(fontSize: 20),
              ),
            )));
  }
}
