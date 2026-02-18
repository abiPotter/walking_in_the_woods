import 'package:flutter/material.dart';
import 'package:my_app/pages/report_page.dart';
import 'package:my_app/pages/profile.dart';
import 'package:my_app/pages/report_management_page.dart';

import '../pages/home_page.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
      body: child,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Column(
        children: [
          Text('Roam and Report', style: TextStyle(fontSize: 24)),
          Text(
            "Roam the Trails, Report the Troubles",
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
      backgroundColor: Colors.blue,
      actions: [
        IconButton(
          icon: Icon(Icons.person),
          onPressed: () {
            //open profile
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => ProfilePage()));
          },
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.blue,
        child: ListView(
          children: [
            DrawerHeader(
              child: Center(
                child: Text('Menu', style: TextStyle(fontSize: 20)),
              ),
            ),
            _drawerItem(
              context,
              title: 'Home',
              icon: Icons.home,
              page: HomePage(),
            ),
            _drawerItem(
              context,
              title: 'Report',
              icon: Icons.report,
              page: ReportPage(),
            ),
            _drawerItem(
              context,
              title: 'Admin',
              icon: Icons.lock,
              page: ReportManagementPage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget page,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontSize: 20)),
      onTap: () {
        Navigator.pop(context); //close drawer
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
    );
  }
}
