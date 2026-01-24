import 'package:flutter/material.dart';
import 'package:my_app/pages/home_page.dart';
import 'package:provider/provider.dart';

import 'helpers/map_ui_state.dart';

void main() {
  runApp(ChangeNotifierProvider(
      create: (_) => MapUiState(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roam and Report',
      theme: ThemeData(
        useMaterial3: false,
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}
