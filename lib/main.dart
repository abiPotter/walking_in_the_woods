import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:roam_and_report/helpers/states/admin_state.dart';
import 'package:roam_and_report/pages/home_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'helpers/states/map_ui_state.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dart:async';

void main() async {
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

  if (supabaseUrl == null ||
      supabaseKey == null ||
      supabaseUrl.isEmpty ||
      supabaseKey.isEmpty) {
    throw Exception("Supabase URL or Key not set");
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MapUiState()),
        ChangeNotifierProvider(create: (_) => AdminState()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roam and Report',
      theme: ThemeData(useMaterial3: false, primarySwatch: Colors.blue),
      home: HomePageWrapper(),
    );
  }
}

class HomePageWrapper extends StatefulWidget {
  const HomePageWrapper({super.key});

  @override
  State<HomePageWrapper> createState() => _HomePageWrapperState();
}

class _HomePageWrapperState extends State<HomePageWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadAdminStatus(context);
    });
  }

  Future<void> loadAdminStatus(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      await FirebaseAuth.instance.signInAnonymously();
      return;
    }

    final adminDoc = await FirebaseFirestore.instance
        .collection('admins')
        .doc(user.uid)
        .get();
    final isAdmin = adminDoc.exists;

    //store admin state in provider
    Provider.of<AdminState>(context, listen: false).setAdmin(isAdmin);
  }

  @override
  Widget build(BuildContext context) {
    return const HomePage();
  }
}
