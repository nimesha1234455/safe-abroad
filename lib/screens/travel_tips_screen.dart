import 'package:flutter/material.dart';
import '../theme.dart';

// General safety tips (no official claims)
class TravelTipsScreen extends StatelessWidget {
  const TravelTipsScreen({super.key});

  static const List<(IconData, String, String)> _tips = [
    (Icons.search, 'Check the license first',
        'Search the agency in this app before you pay anything. Call hotline 1989 if you are unsure.'),
    (Icons.description, 'Get everything in writing',
        'Ask for the job offer, salary, working hours and contract in writing before you travel.'),
    (Icons.receipt_long, 'Keep every receipt',
        'Ask for a receipt for each payment and keep copies of all your documents.'),
    (Icons.badge, 'Protect your passport',
        'Do not hand over your original passport or documents to people you cannot verify.'),
    (Icons.flight_takeoff, 'Use the right visa',
        'A tourist or visit visa is not a work visa. Do not travel for work on one.'),
    (Icons.warning_amber_rounded, 'Beware of offers that are too good',
        'Very high salaries with no skills or experience needed are a warning sign.'),
    (Icons.family_restroom, 'Tell your family',
        'Share your employer details, address and flight information with your family.'),
    (Icons.call, 'Save emergency numbers',
        'Keep hotline 1989 and your embassy number saved before you leave.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Travel Tips')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final t in _tips)
            Card(
              color: Colors.white,
              surfaceTintColor: Colors.transparent,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: kBlue,
                  child: Icon(t.$1, color: Colors.white),
                ),
                title: Text(t.$2,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: kNavy)),
                subtitle: Text(t.$3),
              ),
            ),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'General advice only. Always confirm details with hotline 1989.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}