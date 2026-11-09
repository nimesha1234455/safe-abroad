import 'package:geolocator/geolocator.dart';

class LocationService {
  // Get the phone location, or throw a simple message
  static Future<Position> getCurrentPosition() async {
    // Is GPS turned on?
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw 'Please turn on your phone location (GPS).';
    }

    // Ask for permission if needed
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw 'Location permission was denied.';
    }
    if (permission == LocationPermission.deniedForever) {
      throw 'Location permission is blocked. Please allow it in phone Settings.';
    }

    // Get the location (wait up to 20 seconds)
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      ),
    );
  }

  // Make a Google Maps link from the position
  static String mapLink(Position p) {
    return 'https://maps.google.com/?q=${p.latitude},${p.longitude}';
  }
}