import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class LocationService {
  static Future<LatLng?> getCurrentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    Location location = Location();

    try {
      serviceEnabled = await location.serviceEnabled();
    } on PlatformException {
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

  static Future<LatLng> loadLocation(
      {LatLng defaultLocation = const LatLng(50.7219, -3.5330)}) async {
    //default location is Exeter
    final pos = await getCurrentLocation();
    return pos ?? defaultLocation;
  }
}
