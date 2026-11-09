// Document checklist screen (new design)
// The ticks are saved on the phone

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';

// General checklist (requirements differ by country and job)
class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  static const _key = 'checklist_done';

  // id, title, hint, icon, icon color
  static const List<(String, String, String, IconData, Color)> _items = [
    ('agency', 'Agency license checked',
        'Search the agency in this app before you pay.',
        Icons.account_balance, Color(0xFF1565C0)),
    ('passport', 'Valid passport',
        'Check the validity period needed for your destination.',
        Icons.menu_book, Color(0xFF0A2A6B)),
    ('visa', 'Work visa or permit',
        'A tourist or visit visa is not a work visa.',
        Icons.approval, Color(0xFF1565C0)),
    ('contract', 'Job offer and contract',
        'In writing: salary, duties, working hours.',
        Icons.work, Color(0xFF0A2A6B)),
    ('police', 'Police clearance report', '',
        Icons.gpp_good, Color(0xFF1565C0)),
    ('medical', 'Medical report', '',
        Icons.medical_services, Color(0xFFD32F2F)),
    ('id', 'Birth certificate and ID card', '',
        Icons.badge, Color(0xFF1565C0)),
    ('certs', 'Education and skill certificates', '',
        Icons.school, Color(0xFF0A2A6B)),
    ('photos', 'Passport-size photos', '',
        Icons.photo_camera, Color(0xFF1565C0)),
    ('ticket', 'Ticket and insurance details', '',
        Icons.airplane_ticket, Color(0xFF0A2A6B)),
    ('receipts', 'Receipts for every payment',
        'Never pay without a receipt.',
        Icons.receipt_long, Color(0xFF1565C0)),
    ('copies', 'Copies of all documents',
        'Keep one set with your family.',
        Icons.copy_all, Color(0xFF0A2A6B)),
    ('contacts', 'Emergency numbers saved',
        'Hotline 1989 and your embassy.',
        Icons.phone_in_talk, Color(0xFF2E7D32)),
  ];

  // Ids of the items the user has ticked
  Set<String> _done = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  // Load ticks from the phone
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _done = (prefs.getStringList(_key) ?? []).toSet());
  }

  // Save ticks to the phone
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _done.toList());
  }

  // Tick or untick one item
  void _toggle(String id, bool v) {
    setState(() => v ? _done.add(id) : _done.remove(id));
    _save();
  }

  // Clear all ticks
  void _reset() {
    setState(() => _done.clear());
    _save();
  }

  // Small popup with the details of one item
  void _showDetails((String, String, String, IconData, Color) item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(item.$4, color: item.$5, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(item.$2,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: kNavy)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Show the hint, or a general tip if there is no hint
            Text(
              item.$3.isEmpty
                  ? 'Keep the original safe and carry a photocopy.'
                  : item.$3,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 10),
            const Text(
              'Requirements differ by country and job. '
              'Confirm with your agency and hotline 1989.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  // Blue header at the top of the page
  Widget _header() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A2A6B), Color(0xFF1565C0)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 22),
          child: Row(
            children: [
              // Round back button
              CircleAvatar(
                backgroundColor: Colors.white24,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 12),
              // Title and sub title
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Document',
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    Text('Checklist',
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: kGold)),
                    Text('Prepare your documents for a safe journey...',
                        style: TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: Colors.white70)),
                  ],
                ),
              ),
              // Reset button
              IconButton(
                tooltip: 'Reset',
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _reset,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Progress box: "x of y ready", bar and percent
  Widget _progressBox(int count, int total) {
    final percent = total == 0 ? 0 : (count * 100 / total).round();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFDCE9FB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Clipboard icon in a blue circle
          const CircleAvatar(
            radius: 26,
            backgroundColor: kNavy,
            child: Icon(Icons.checklist, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$count of $total ready',
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: kNavy)),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: total == 0 ? 0 : count / total,
                  minHeight: 10,
                  color: kGreen,
                  backgroundColor: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Percent chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text('$percent%',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: kNavy)),
          ),
        ],
      ),
    );
  }

  // One checklist card
  Widget _itemCard((String, String, String, IconData, Color) item) {
    final checked = _done.contains(item.$1);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        // Tap anywhere on the card to tick or untick
        onTap: () => _toggle(item.$1, !checked),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Row(
            children: [
              // Checkbox
              Checkbox(
                value: checked,
                activeColor: kGreen,
                onChanged: (v) => _toggle(item.$1, v ?? false),
              ),
              // Icon box
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCE9FB),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.$4, color: item.$5, size: 28),
              ),
              const SizedBox(width: 12),
              // Title and small hint
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.$2,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: kNavy,
                            // Line through the title when ticked
                            decoration:
                                checked ? TextDecoration.lineThrough : null)),
                    if (item.$3.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(item.$3,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54)),
                      ),
                  ],
                ),
              ),
              // Arrow button opens the details popup
              IconButton(
                tooltip: 'Details',
                icon: const Icon(Icons.chevron_right, color: kNavy),
                onPressed: () => _showDetails(item),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Tip box at the bottom
  Widget _tipBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFDCE9FB),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: kNavy,
            child: Icon(Icons.info_outline, color: Colors.white),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tip!',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kNavy)),
                Text(
                  'Make sure all documents are valid and up to date '
                  'before you apply.',
                  style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: kNavy),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _items.length;
    final count = _done.length;
    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          _header(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _progressBox(count, total),
                const SizedBox(height: 14),
                for (final item in _items) _itemCard(item),
                const SizedBox(height: 4),
                _tipBox(),
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'General list only. Requirements differ by country and '
                    'job. Confirm with your agency and hotline 1989.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}