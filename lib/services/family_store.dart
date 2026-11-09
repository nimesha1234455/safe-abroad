import 'package:shared_preferences/shared_preferences.dart';

// One family contact
// (relation is new. Old saved contacts without it become "Other".)
class FamilyContact {
  final String name;
  final String phone;
  final String relation;
  FamilyContact(this.name, this.phone, [this.relation = 'Other']);
}

// Saves family contacts on the phone only
class FamilyStore {
  static const String _key = 'family_contacts';

  // Choices shown when adding a contact
  static const List<String> relations = [
    'Mother',
    'Father',
    'Brother',
    'Sister',
    'Wife',
    'Husband',
    'Friend',
    'Other',
  ];

  // Load saved contacts
  static Future<List<FamilyContact>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.map((s) {
      final parts = s.split('|');
      return FamilyContact(
        parts[0],
        parts.length > 1 ? parts[1] : '',
        parts.length > 2 && parts[2].isNotEmpty ? parts[2] : 'Other',
      );
    }).toList();
  }

  // Save all contacts
  static Future<void> save(List<FamilyContact> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      contacts.map((c) => '${c.name}|${c.phone}|${c.relation}').toList(),
    );
  }

  // Change a Sri Lankan number to international format (digits only)
  // Example: 0771234567 becomes 94771234567
  static String intlNumber(String phone) {
    var d = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (d.startsWith('00')) {
      d = d.substring(2);
    } else if (d.startsWith('0')) {
      d = '94${d.substring(1)}';
    }
    return d;
  }
}