import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:roam_and_report/helpers/states/admin_state.dart';
import 'package:roam_and_report/pages/admin_login_page.dart';
import 'package:roam_and_report/pages/analytics_page.dart';
import 'package:roam_and_report/pages/help_page.dart';
import 'package:roam_and_report/pages/report_page.dart';
import 'package:roam_and_report/pages/profile_page.dart';
import 'package:roam_and_report/pages/report_management_page.dart';
import 'package:roam_and_report/pages/home_page.dart';

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
          onLongPress: () {
            //open admin login
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminLoginPage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final isAdmin = Provider.of<AdminState>(context).isAdmin;

    return Drawer(
      child: Container(
        color: Colors.blue,
        child: ListView(
          children: [
            DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/logo.png', width: 90),
                  SizedBox(height: 10),
                  Text(
                    'Menu',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ],
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
            if (isAdmin)
              _drawerItem(
                context,
                title: 'Analytics',
                icon: Icons.analytics,
                page: AnalyticsPage(),
              ),
            if (isAdmin)
              _drawerItem(
                context,
                title: 'Admin',
                icon: Icons.lock,
                page: ReportManagementPage(),
              ),
            _drawerItem(
              context,
              title: 'About & Help',
              icon: Icons.help,
              page: HelpPage(),
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
