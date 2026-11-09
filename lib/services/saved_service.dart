import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/agency.dart';

// Keeps saved agencies on the phone
class SavedService {
  static const _key = 'saved_agencies';

  static String keyOf(Agency a) => '${a.licenseNo}|${a.name}';

  static Map<String, dynamic> _toMap(Agency a) => {
        'id': a.id,
        'name': a.name,
        'license_no': a.licenseNo,
        'address': a.address,
        'phone': a.phone,
        'email': a.email,
        'status': a.status,
        'valid_upto': a.validUpto,
      };

  static Future<List<Agency>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList(_key) ?? [];
    final result = <Agency>[];
    for (final s in items) {
      try {
        result.add(Agency.fromJson(jsonDecode(s) as Map<String, dynamic>));
      } catch (_) {
        // skip a broken entry
      }
    }
    return result;
  }

  static Future<void> _save(List<Agency> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _key, list.map((a) => jsonEncode(_toMap(a))).toList());
  }

  // Save if not saved, remove if already saved
  static Future<void> toggle(Agency a) async {
    final list = await load();
    final i = list.indexWhere((x) => keyOf(x) == keyOf(a));
    if (i >= 0) {
      list.removeAt(i);
    } else {
      list.insert(0, a);
    }
    await _save(list);
  }
}