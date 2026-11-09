// Agency data model (matches the Laravel API fields)
class Agency {
  final int id;
  final String name;
  final String licenseNo;
  final String? address;
  final String? phone;
  final String? email;
  final String status; // registered / suspended / cancelled
  final String? validUpto; // format: 2027-09-30

  Agency({
    required this.id,
    required this.name,
    required this.licenseNo,
    this.address,
    this.phone,
    this.email,
    required this.status,
    this.validUpto,
  });

  // Create an Agency object from JSON data
  factory Agency.fromJson(Map<String, dynamic> json) {
    return Agency(
      id: json['id'] ?? 0,
      name: (json['name'] ?? '').toString(),
      licenseNo: (json['license_no'] ?? '').toString(),
      address: json['address']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      status: (json['status'] ?? 'registered').toString(),
      validUpto: json['valid_upto']?.toString(),
    );
  }

  bool get isRegistered => status == 'registered';

  // valid_upto as a date (null if missing)
  DateTime? get validUptoDate =>
      validUpto == null ? null : DateTime.tryParse(validUpto!);

  // True when the license date is already in the past
  bool get isExpired {
    final d = validUptoDate;
    if (d == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return d.isBefore(today);
  }

  // Days left until the license expires (negative if already expired)
  int? get daysLeft {
    final d = validUptoDate;
    if (d == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return d.difference(today).inDays;
  }

  // Clean phone numbers that can be dialed (bad or short ones are dropped)
  List<String> get phones {
    if (phone == null) return [];
    final result = <String>[];
    for (final p in phone!.split(RegExp(r'[,/;]'))) {
      final cleaned = p.replaceAll(RegExp(r'[^0-9+]'), '');
      if (cleaned.length >= 9 && cleaned.length <= 13 && !result.contains(cleaned)) {
        result.add(cleaned);
      }
    }
    return result;
  }

  // First valid email found in the text
  String? get firstEmail {
    if (email == null) return null;
    final m = RegExp(r'[\w.+-]+@[\w-]+(\.[\w-]+)+').firstMatch(email!);
    return m?.group(0);
  }
}