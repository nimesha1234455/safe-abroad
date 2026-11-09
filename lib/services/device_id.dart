import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

// Makes and remembers a random id for this phone (no personal data)
class DeviceId {
  static const String _key = 'device_id';
  static String? _cached;

  // Get the saved id, or make a new one the first time
  static Future<String> get() async {
    if (_cached != null) return _cached!;

    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_key);

    if (id == null) {
      // 32 random hex characters
      final r = Random.secure();
      id = List.generate(32, (_) => r.nextInt(16).toRadixString(16)).join();
      await prefs.setString(_key, id);
    }

    _cached = id;
    return id;
  }
}