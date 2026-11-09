// Embassy contacts screen (new design)
// The user saves their own contacts. They stay on the phone.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';

// Your own important contacts (embassy, employer, family)
class EmbassyScreen extends StatefulWidget {
  const EmbassyScreen({super.key});

  @override
  State<EmbassyScreen> createState() => _EmbassyScreenState();
}

class _EmbassyScreenState extends State<EmbassyScreen> {
  static const _key = 'my_contacts';
  List<Map<String, String>> _contacts = [];

  // Text typed in the search box
  final _searchC = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  // Load saved contacts from the phone
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList(_key) ?? [];
    final list = <Map<String, String>>[];
    for (final s in items) {
      try {
        list.add(Map<String, String>.from(jsonDecode(s) as Map));
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() => _contacts = list);
  }

  // Save contacts to the phone
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _contacts.map(jsonEncode).toList());
  }

  // Show a popup to add a new contact
  Future<void> _add() async {
    final nameC = TextEditingController();
    final numC = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameC,
              decoration: const InputDecoration(
                  labelText: 'Name (e.g. Embassy in Doha)'),
            ),
            TextField(
              controller: numC,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone number'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save')),
        ],
      ),
    );
    final name = nameC.text.trim();
    final number = numC.text.trim();
    nameC.dispose();
    numC.dispose();
    if (ok == true && name.isNotEmpty && number.isNotEmpty) {
      setState(() => _contacts.add({'name': name, 'number': number}));
      await _save();
    }
  }

  // Ask before deleting a contact
  Future<void> _delete(int index) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete contact?'),
        content: Text(_contacts[index]['name'] ?? ''),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) {
      setState(() => _contacts.removeAt(index));
      await _save();
    }
  }

  // Open the phone dialer
  Future<void> _call(String number) async {
    await launchUrl(Uri(scheme: 'tel', path: number));
  }

  // Search the contact name in Google Maps (opens the browser or Maps app)
  Future<void> _openMap(String name) async {
    final uri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': name,
    });
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // Open the Foreign Ministry home page
  Future<void> _openMfa() async {
    await launchUrl(Uri.https('www.mfa.gov.lk'),
        mode: LaunchMode.externalApplication);
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
                    Text('Embassy',
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    Text('Contacts',
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: kGold)),
                    Text('Save the numbers you may need abroad',
                        style: TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: Colors.white70)),
                  ],
                ),
              ),
              // Plane icon on the right
              Transform.rotate(
                angle: -0.4,
                child:
                    const Icon(Icons.flight, color: Colors.white54, size: 60),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Blue info box under the header
  Widget _infoBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFDCE9FB),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info, color: kBlue, size: 30),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Save the numbers you may need abroad: your embassy or '
                  'consulate, your employer and your family. They stay on '
                  'your phone.',
                  style: TextStyle(fontSize: 13, color: kNavy),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Link to the Foreign Ministry home page
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: kNavy,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
            ),
            icon: const Icon(Icons.public, size: 18),
            label: const Text('Find embassy details (Foreign Ministry)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            onPressed: _openMfa,
          ),
        ],
      ),
    );
  }

  // Search box
  Widget _searchBox() {
    return TextField(
      controller: _searchC,
      onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
      decoration: InputDecoration(
        hintText: 'Search by name...',
        prefixIcon: const Icon(Icons.search, color: kBlue),
        // Clear button shows only when something is typed
        suffixIcon: _query.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  _searchC.clear();
                  setState(() => _query = '');
                },
              ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFFBBD6F5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFFBBD6F5)),
        ),
      ),
    );
  }

  // Small round icon button with a label under it (Call / Map)
  Widget _roundAction(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFFDCE9FB),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: kNavy)),
          ],
        ),
      ),
    );
  }

  // One contact card
  Widget _contactCard(int index) {
    final name = _contacts[index]['name'] ?? '';
    final number = _contacts[index]['number'] ?? '';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Round icon on the left
          const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.teal,
            child: Icon(Icons.account_balance, color: Colors.white),
          ),
          const SizedBox(width: 12),
          // Name and phone number
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kNavy)),
                const SizedBox(height: 2),
                Text(number,
                    style:
                        const TextStyle(fontSize: 13, color: Colors.black54)),
              ],
            ),
          ),
          // Call and Map buttons
          _roundAction(Icons.call, 'Call', kGreen, () => _call(number)),
          _roundAction(Icons.location_on, 'Map', kBlue, () => _openMap(name)),
          // Delete button
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline, color: Colors.black45),
            onPressed: () => _delete(index),
          ),
        ],
      ),
    );
  }

  // "Need more help?" box at the bottom
  Widget _helpBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFE3F0FF), Color(0xFFC9E0FA)]),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBBD6F5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.headset_mic, color: kBlue, size: 38),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Need more help?',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: kNavy)),
                Text('Call the SLBFE hotline',
                    style: TextStyle(fontSize: 12, color: kNavy)),
              ],
            ),
          ),
          // Calls the hotline 1989
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: kNavy,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
            ),
            onPressed: () => _call('1989'),
            icon: const Icon(Icons.call, size: 16),
            label: const Text('Hotline 1989',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Find which contacts match the search text
    // We keep the original index so delete works correctly
    final shown = <int>[];
    for (var i = 0; i < _contacts.length; i++) {
      final name = (_contacts[i]['name'] ?? '').toLowerCase();
      if (_query.isEmpty || name.contains(_query)) shown.add(i);
    }

    return Scaffold(
      backgroundColor: kBg,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kNavy,
        foregroundColor: Colors.white,
        onPressed: _add,
        icon: const Icon(Icons.add),
        label: const Text('Add contact'),
      ),
      body: Column(
        children: [
          _header(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              children: [
                _infoBox(),
                const SizedBox(height: 12),
                _searchBox(),
                const SizedBox(height: 14),

                // Message when the list is empty
                if (_contacts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No contacts yet. Tap "Add contact".',
                        textAlign: TextAlign.center),
                  )
                else if (shown.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No contacts match your search.',
                        textAlign: TextAlign.center),
                  ),

                // Contact cards
                for (final i in shown) _contactCard(i),

                const SizedBox(height: 6),
                _helpBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}