import 'package:flutter/material.dart';
import 'package:my_app/pages/home_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'helpers/map_ui_state.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Supabase.initialize(
    url: 'https://lcqiwqwygtiiachcolzy.supabase.co',
    anonKey: 'sb_publishable_Qm2mC6tHL4T_4edfWsIeHQ_WW7H5rLj',
  );

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
      home: HomePage(),
    );
  }
}
