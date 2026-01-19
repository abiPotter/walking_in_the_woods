import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../layout/main_layout.dart';

import 'package:location/location.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: MapContainer(),
    );
  }
}

class MapContainer extends StatefulWidget {
  const MapContainer({super.key});

  @override
  State<MapContainer> createState() => _MapContainerState();
}

class _MapContainerState extends State<MapContainer> {
  LatLng? _position;
  bool _usingDefaultLocation = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadLocation();
    });
  }

  Future<void> _loadLocation() async {
    LatLng? position = await getCurrentLocation();

    position = await getCurrentLocation();

    if (position == null) {
      // GPS not available, use default location
      setState(() {
        _position = LatLng(50.7219, -3.5330); // Exeter;
        _usingDefaultLocation = true;
      });
    } else {
      // GPS available
      setState(() {
        _position = position;
        _usingDefaultLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_position == null) {
      // still loading the map
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text(
              'Loading map...',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final size = MediaQuery.of(context).size;

    return Stack(children: [
      SizedBox(
        width: size.width,
        height: size.height * 0.75,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: _position ?? LatLng(10, 10),
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
      ),
      if (_usingDefaultLocation)
        // display a popup box telling the user GPS location could not be used, and so map has loaded to default location (Exeter)
        Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Text(
              'GPS unavailable - showing default location.\nPlease check your device settings.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
    ]);
  }

  Future<LatLng?> getCurrentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    Location location = Location();

    try {
      serviceEnabled = await location.serviceEnabled();
    } on PlatformException catch (e) {
      // this error will always occur as the Location is not setup before this line is reached
      // treat it as though the service is not enabled
      serviceEnabled = false;
    }
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }
    LocationData locationData = await location.getLocation();

    if (locationData.latitude == null || locationData.longitude == null) {
      return null;
    }

    return LatLng(locationData.latitude!, locationData.longitude!);
  }
}
