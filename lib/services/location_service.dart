import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<LatLng?> getCurrentLocation() async {
    try {
      bool serviceEnabled;

      try {
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
      } on PlatformException {
        // this error will always occur as the Location is not setup before this line is reached
        // treat it as though the service is not enabled
        serviceEnabled = false;
      }
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          return null;
        }
      }

      LocationPermission permissionGranted = await Geolocator.checkPermission();
      if (permissionGranted == LocationPermission.denied ||
          permissionGranted == LocationPermission.deniedForever) {
        permissionGranted = await Geolocator.requestPermission();
        if (permissionGranted == LocationPermission.denied) {
          return null;
        }
      }

      if (permissionGranted == LocationPermission.deniedForever) {
        return null;
      }

      final locationData = await Geolocator.getCurrentPosition();

      return LatLng(locationData.latitude, locationData.longitude);
    } catch (e) {
      return null;
    }
  }

  static Future<LatLng> loadLocation({
    LatLng defaultLocation = const LatLng(0, 0),
  }) async {
    //default location is world map
    final pos = await getCurrentLocation();
    return pos ?? defaultLocation;
  }
}
