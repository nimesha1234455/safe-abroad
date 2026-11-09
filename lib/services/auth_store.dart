import 'package:shared_preferences/shared_preferences.dart';

// Keeps the login token and phone number on the device.
// Put this file at: lib/services/auth_store.dart
class AuthStore {
  static const _tokenKey = 'auth_token';
  static const _phoneKey = 'auth_phone';

  static Future<void> save({String? token, required String phone}) async {
    final p = await SharedPreferences.getInstance();
    if (token != null) await p.setString(_tokenKey, token);
    await p.setString(_phoneKey, phone);
  }

  static Future<String?> token() async =>
      (await SharedPreferences.getInstance()).getString(_tokenKey);

  static Future<String?> phone() async =>
      (await SharedPreferences.getInstance()).getString(_phoneKey);

  static Future<bool> isLoggedIn() async => (await phone()) != null;

  static Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_tokenKey);
    await p.remove(_phoneKey);
  }
}