import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

// Phone + OTP login. The server makes and checks the code.
class AuthService {
  static const _tokenKey = 'auth_token';
  static const _phoneKey = 'auth_phone';
  static const _guestKey = 'guest_mode';

  static Future<Map<String, dynamic>> _post(
      String path, Map<String, dynamic> body) async {
    final response = await http
        .post(
          Uri.parse('${ApiService.baseUrl}$path'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 20));

    Map<String, dynamic> data = {};
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {}

    if (response.statusCode != 200) {
      throw AuthException(
          (data['error'] ?? data['message'] ?? 'Something went wrong (${response.statusCode})')
              .toString());
    }
    return data;
  }

  // phone looks like +94771234567
  static Future<void> sendOtp(String phone) async {
    await _post('/auth/send-otp', {'phone': phone});
  }

  static Future<void> verifyOtp(String phone, String code) async {
    final data = await _post('/auth/verify-otp', {'phone': phone, 'code': code});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, (data['token'] ?? '').toString());
    await prefs.setString(_phoneKey, (data['phone'] ?? phone).toString());
    await prefs.remove(_guestKey);
    // Fill the phone number in My Account if it is empty
    if ((prefs.getString('profile_phone') ?? '').isEmpty) {
      await prefs.setString('profile_phone', phone);
    }
  }

  static Future<void> continueAsGuest() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_guestKey, true);
  }

  // True when the user is logged in or chose Guest before
  static Future<bool> shouldSkipLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey) ?? '';
    return token.isNotEmpty || (prefs.getBool(_guestKey) ?? false);
  }

  static Future<String?> token() async {
    final prefs = await SharedPreferences.getInstance();
    final t = prefs.getString(_tokenKey);
    return (t == null || t.isEmpty) ? null : t;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_phoneKey);
    await prefs.remove(_guestKey);
  }
}