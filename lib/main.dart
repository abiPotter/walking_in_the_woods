import 'package:flutter/material.dart';
import 'package:my_app/pages/first_page.dart';
import 'package:my_app/pages/profile.dart';
import 'package:my_app/pages/second_page.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme o
        //
        //f your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        useMaterial3: false,
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text("Roam and Report"),
          backgroundColor: Colors.blue,

          actions: [
            IconButton(
              onPressed: () {
                //open profile
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ProfilePage()));
              },
              icon: Icon(Icons.person),
            ),
          ],
        ),
        drawer: Drawer(
          child: Container(
            color: Colors.blue,
            child: ListView(children: [
              DrawerHeader(
                child: Center(child: Text('Menu')),
              ),
              ListTile(
                  leading: Icon(Icons.home),
                  title: Text(
                    'Page 1',
                    style: TextStyle(fontSize: 20),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => FirstPage()));
                  }),
              ListTile(
                  leading: Icon(Icons.home),
                  title: Text(
                    'Page 2',
                    style: TextStyle(fontSize: 20),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => SecondPage()));
                  })
            ]),
          ),
        ),
        body: Container(
          width: 450,
          height: 650,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent),
            borderRadius: BorderRadius.circular(12),
          ),
          child: FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(50.7371, -3.5318),
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=pOhyO2fVFGnndUVzQFX8',
                userAgentPackageName: 'com.undergrad_proj.walking_in_the_woods',
              ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    '© MapTiler © OpenStreetMap contributors',
                    onTap: () => launchUrl(
                      Uri.parse('https://www.maptiler.com/copyright/'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
