import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../layout/main_layout.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: MapContainer(),
    );
  }
}

class MapContainer extends StatelessWidget {
  const MapContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 450,
      height: 650,
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
    );
  }
}
