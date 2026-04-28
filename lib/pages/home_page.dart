import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:roam_and_report/services/report_provider.dart';
import 'package:roam_and_report/widgets/report_details.dart';
import 'package:roam_and_report/widgets/map_container.dart';
import 'package:roam_and_report/helpers/states/map_ui_state.dart';
import 'package:roam_and_report/layout/main_layout.dart';
import 'report_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _canLoadMap = false;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    //show a prototype warning if first launch
    final prefs = await SharedPreferences.getInstance();
    final bool hasSeenPrototypeDialog =
        prefs.getBool('hasSeenPrototypeWarning') ?? false;

    if (!hasSeenPrototypeDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPrototypeWarningDialog();
      });
    } else {
      setState(() {
        _canLoadMap = true;
      });
    }
  }

  Future<void> _showPrototypeWarningDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.all(16),
          title: Column(
            children: const [
              Icon(Icons.explore, size: 48, color: Colors.blue),
              SizedBox(height: 12),
              Text("Prototype & Safety Notice", textAlign: TextAlign.center),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                "This app is a prototype. The reports shown are for demonstration only and may not reflect real-world conditions.",
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),

              Text(
                "(You are not required to go outdoors to test this app)",
                textAlign: TextAlign.center,
                style: TextStyle(fontStyle: FontStyle.italic),
              ),

              SizedBox(height: 16),

              Row(
                children: [
                  Icon(Icons.warning, size: 20, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Stay aware of your surroundings and be extra careful in unfamiliar areas",
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.my_location, size: 20, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text("Allow location access for best results"),
                  ),
                ],
              ),

              SizedBox(height: 16),

              Text(
                "If you don't allow location access, the map will centre on world map and you'll need to find your location manually.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  //set shared preferences so will not see warning again
                  await prefs.setBool('hasSeenPrototypeWarning', true);
                  Navigator.of(context).pop();
                  setState(() {
                    _canLoadMap = true;
                  });
                },
                child: const Text("Continue", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = context.watch<MapUiState>().keyboardOpen;
    final reports = ReportProvider().getAllReports();

    return MainLayout(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: _canLoadMap
                  ? MapContainer(
                      allReports: reports,
                      showReportsToggle: true,
                      showSearchBar: true,
                      showRecentre: true,
                      isShowingReportDetails: false,
                      onMarkerTap: (report) {
                        showDialog(
                          context: context,
                          builder: (_) => ReportDetails(
                            report: report,
                            isOnReportManagement: false,
                            isOnUserProfile: false,
                            onStatusChanged: () {},
                          ),
                        );
                      },
                      onLocationSelected: (latLng) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Create Report'),
                              content: Text(
                                'Do you want to make a report at this location?\n\nLat: ${latLng.latitude.toStringAsFixed(5)}, Lng: ${latLng.longitude.toStringAsFixed(5)}',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false), // cancel
                                  child: const Text('No'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ReportPage(initialLocation: latLng),
                                    ),
                                  ), // confirm
                                  child: const Text('Yes'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
            if (!keyboardOpen)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: FloatingActionButton.extended(
                  onPressed: () {
                    //open report page
                    Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (_) => ReportPage()));
                  },
                  icon: const Icon(Icons.report),
                  label: const Text('Report'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
