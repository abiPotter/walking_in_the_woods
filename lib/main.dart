import 'package:flutter/material.dart';
import 'package:my_app/pages/home_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'helpers/map_ui_state.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dart:async';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    if (!kIsWeb) {
      await dotenv.load(fileName: ".env"); // not running on web
    }

    final supabaseUrl = kIsWeb
      ? const String.fromEnvironment('SUPABASE_URL')
      : dotenv.env['SUPABASE_URL'];
    final supabaseKey = kIsWeb
      ? const String.fromEnvironment('SUPABASE_ANONKEY')
      : dotenv.env['SUPABASE_ANONKEY'];

    if (supabaseUrl == null || supabaseKey == null || supabaseUrl.isEmpty || supabaseKey.isEmpty) {
      throw Exception("Supabase URL or Key not set");
    }

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
    await ensureSignedIn();

    runApp(ChangeNotifierProvider(
        create: (_) => MapUiState(), child: const MyApp()));
  }, (error, stack) {
    print("Uncaught error in Flutter Web: $error\n$stack");
  });
}

Future<void> ensureSignedIn() async {
  final auth = FirebaseAuth.instance;
  if (auth.currentUser == null) {
    await auth.signInAnonymously();
  }
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
      home: HomePage(),
    );
  }
}
