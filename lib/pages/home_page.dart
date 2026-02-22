import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/map_container.dart';
import '../helpers/states/map_ui_state.dart';
import '../layout/main_layout.dart';

import 'report_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = context.watch<MapUiState>().keyboardOpen;

    return MainLayout(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: MapContainer(
                showReportsToggle: true,
                showSearchBar: true,
                showRecentre: true,
                isShowingReportDetails: false,
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
              ),
            ),
            if (!keyboardOpen)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: FloatingActionButton.extended(
                  onPressed: () {
                    //open profile
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
