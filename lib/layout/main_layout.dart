import 'package:flutter/material.dart';
import 'package:my_app/pages/first_page.dart';
import 'package:my_app/pages/profile.dart';
import 'package:my_app/pages/second_page.dart';

import '../main.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Walking in the Woods"),
        backgroundColor: Colors.blue,

        actions: [
          IconButton(
            onPressed: () {
              //open profile
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => ProfilePage()));
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
                  'Home',
                  style: TextStyle(fontSize: 20),
                ),
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => MyApp()));
                }),
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
      body: child,
    );
  }
}
