// Agency checker screen (new design)
// Search an agency by name or license number and see its status

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/agency.dart';
import '../services/api_service.dart';
import '../services/saved_service.dart';
import '../theme.dart';

class CheckerScreen extends StatefulWidget {
  // If given, the search runs right away (used by the Saved screen)
  final String? initialQuery;
  const CheckerScreen({super.key, this.initialQuery});

  @override
  State<CheckerScreen> createState() => _CheckerScreenState();
}

class _CheckerScreenState extends State<CheckerScreen> {
  // Key used to keep recent searches on the phone
  static const _recentKey = 'recent_searches';

  final _controller = TextEditingController();
  List<Agency> _results = [];
  bool _loading = false;
  bool _searched = false;
  String? _error;
  Set<String> _saved = {};

  // Last searched texts (only the text, not the result)
  List<String> _recent = [];

  @override
  void initState() {
    super.initState();
    _loadSaved();
    _loadRecent();
    final q = widget.initialQuery;
    if (q != null && q.isNotEmpty) {
      _controller.text = q;
      WidgetsBinding.instance.addPostFrameCallback((_) => _search());
    }
  }

  Future<void> _loadSaved() async {
    final list = await SavedService.load();
    if (!mounted) return;
    setState(() => _saved = list.map(SavedService.keyOf).toSet());
  }

  // Load recent searches from the phone
  Future<void> _loadRecent() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _recent = prefs.getStringList(_recentKey) ?? []);
  }

  // Add a text to the top of the recent list (max 5, no duplicates)
  Future<void> _addRecent(String text) async {
    final list = List<String>.from(_recent);
    list.removeWhere((e) => e.toLowerCase() == text.toLowerCase());
    list.insert(0, text);
    final short = list.take(5).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentKey, short);
    if (!mounted) return;
    setState(() => _recent = short);
  }

  // Clear all recent searches
  Future<void> _clearRecent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentKey);
    if (!mounted) return;
    setState(() => _recent = []);
  }

  Future<void> _toggleSave(Agency a) async {
    final wasSaved = _saved.contains(SavedService.keyOf(a));
    await SavedService.toggle(a);
    await _loadSaved();
    if (mounted) _msg(wasSaved ? 'Removed from Saved' : 'Saved');
  }

  Future<void> _search() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ApiService.searchAgencies(text);
      if (!mounted) return;
      setState(() {
        _results = data;
        _searched = true;
      });
      // Remember this search
      await _addRecent(text);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Could not connect. Check your internet.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Run a search again from the recent list
  void _searchAgain(String text) {
    _controller.text = text;
    _search();
  }

  Color _color(Agency a) {
    if (a.status == 'cancelled') return kRed;
    if (a.status == 'suspended') return kOrange;
    return a.isExpired ? kOrange : kGreen;
  }

  String _label(Agency a) {
    if (a.status == 'cancelled') return 'CANCELLED';
    if (a.status == 'suspended') return 'SUSPENDED';
    return a.isExpired ? 'LICENSE EXPIRED' : 'REGISTERED';
  }

  IconData _icon(Agency a) {
    if (a.status == 'cancelled') return Icons.cancel;
    if (a.status == 'suspended' || a.isExpired) return Icons.warning_rounded;
    return Icons.check_circle;
  }

  String _date(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _call(String n) async {
    final ok = await launchUrl(Uri(scheme: 'tel', path: n));
    if (!ok && mounted) _msg('Could not open the dialer');
  }

  Future<void> _mail(String e) async {
    final ok = await launchUrl(Uri(scheme: 'mailto', path: e));
    if (!ok && mounted) _msg('Could not open the email app');
  }

  Future<void> _map(String address) async {
    final uri = Uri.https('www.google.com', '/maps/search/',
        {'api': '1', 'query': '$address, Sri Lanka'});
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) _msg('Could not open maps');
  }

  // Share the result through WhatsApp
  Future<void> _share(Agency a) async {
    final date = a.validUptoDate;
    final validLine = date != null ? 'Valid upto: ${_date(date)}\n' : '';
    final text = 'Agency check (Safe Abroad)\n'
        'Name: ${a.name}\n'
        'License No: ${a.licenseNo}\n'
        'Status: ${_label(a)}\n'
        '${validLine}Please confirm with hotline 1989.';
    final ok = await launchUrl(
        Uri.https('wa.me', '/', {'text': text}),
        mode: LaunchMode.externalApplication);
    if (!ok && mounted) _msg('Could not open WhatsApp');
  }

  void _msg(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ---------- NEW DESIGN PARTS ----------

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
                    Text.rich(
                      TextSpan(children: [
                        TextSpan(
                            text: 'Agency ',
                            style: TextStyle(color: Colors.white)),
                        TextSpan(
                            text: 'Checker', style: TextStyle(color: kGold)),
                      ]),
                      style: TextStyle(
                          fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    Text('Verify before you pay',
                        style: TextStyle(
                            fontSize: 14,
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

  // Search box with the blue search button
  Widget _searchBox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 14),
            child: Icon(Icons.search, color: kBlue),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              // Go back to the home view when the text is cleared
              onChanged: (v) {
                if (v.trim().isEmpty && _searched) {
                  setState(() {
                    _searched = false;
                    _results = [];
                    _error = null;
                  });
                }
              },
              decoration: const InputDecoration(
                hintText: 'Enter agency name or license number',
                hintStyle: TextStyle(fontSize: 14),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 16),
              ),
            ),
          ),
          // Blue search button
          Padding(
            padding: const EdgeInsets.all(6),
            child: Material(
              color: kNavy,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _search,
                child: const SizedBox(
                  width: 52,
                  height: 46,
                  child: Icon(Icons.search, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Quick tips box
  Widget _quickTips() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFE3F0FF), Color(0xFFC9E0FA)]),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBBD6F5)),
      ),
      child: const Row(
        children: [
          Icon(Icons.verified_user, color: kBlue, size: 52),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quick tips',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kNavy)),
                SizedBox(height: 2),
                Text('Check the licence status before making any payment.',
                    style: TextStyle(fontSize: 14, color: kNavy)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // One small status card (Registered / Suspended / Cancelled)
  Widget _statusCard(IconData icon, Color color, String title, String info) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        // Tap to see what the status means
        onTap: () => _msg(info),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 38),
              const SizedBox(height: 6),
              Text(title,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: kNavy)),
              const SizedBox(height: 8),
              // Small coloured line under the text
              Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // The three status cards in a row
  Widget _statusRow() {
    return Row(
      children: [
        _statusCard(Icons.check_circle, kGreen, 'Registered',
            'Registered: found in the SLBFE valid agency list.'),
        const SizedBox(width: 10),
        _statusCard(Icons.pause_circle_filled, kOrange, 'Suspended',
            'Suspended: temporarily stopped. Do not pay or give documents.'),
        const SizedBox(width: 10),
        _statusCard(Icons.cancel, kRed, 'Cancelled',
            'Cancelled: the license is cancelled. Do not pay or give documents.'),
      ],
    );
  }

  // Recent searches list with a Clear All button
  Widget _recentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.history, color: kNavy),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('Recent Searches',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kNavy)),
            ),
            if (_recent.isNotEmpty)
              TextButton(
                onPressed: _clearRecent,
                child: const Text('Clear All'),
              ),
          ],
        ),
        const SizedBox(height: 6),
        if (_recent.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('No recent searches yet.',
                style: TextStyle(color: Colors.black54)),
          ),
        for (final r in _recent)
          Container(
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
            child: ListTile(
              onTap: () => _searchAgain(r),
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFDCE9FB),
                child: Icon(Icons.business, color: kNavy),
              ),
              title: Text(r,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: kNavy)),
              subtitle: const Text('Tap to search again'),
              trailing: const Icon(Icons.chevron_right, color: kNavy),
            ),
          ),
      ],
    );
  }

  // Note at the bottom
  Widget _noteBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFDCE9FB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBBD6F5)),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: kNavy,
            child: Icon(Icons.info_outline, color: Colors.white, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Personal app, not a government app. '
              'Confirm details with official SLBFE sources or hotline 1989.',
              style: TextStyle(fontSize: 12, color: kNavy),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- RESULT CARD (same logic as before) ----------

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
            Text(value,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      );

  Widget _buildCard(Agency a) {
    final color = _color(a);
    final date = a.validUptoDate;
    final left = a.daysLeft;
    final email = a.firstEmail;
    final hasAddress = a.address != null && a.address!.isNotEmpty;
    final isSaved = _saved.contains(SavedService.keyOf(a));

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status banner with the bookmark button
          Container(
            color: color,
            padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
            child: Row(children: [
              Icon(_icon(a), color: Colors.white, size: 30),
              const SizedBox(width: 10),
              Expanded(
                child: Text(_label(a),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ),
              IconButton(
                tooltip: isSaved ? 'Remove from Saved' : 'Save',
                icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: Colors.white, size: 28),
                onPressed: () => _toggleSave(a),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row('Agency Name', a.name),
                _row('License No', a.licenseNo),
                if (hasAddress) _row('Address', a.address!),
                if (date != null)
                  _row(
                    a.isExpired ? 'Expired on' : 'Valid Upto',
                    left != null && left >= 0 && left <= 60
                        ? '${_date(date)}  (in $left days)'
                        : _date(date),
                  ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    a.status == 'cancelled'
                        ? 'මේ Agency එකේ license එක cancel කරලා තියෙනවා. මුදල් ගෙවීම හෝ ලේඛන භාර දීම නොකරන්න.\n'
                            'This license is cancelled. Do not pay money or give documents.'
                        : a.status == 'suspended'
                            ? 'මේ Agency එක තාවකාලිකව suspend කරලා. මුදල් ගෙවීම හෝ ලේඛන භාර දීම නොකරන්න.\n'
                                'Temporarily suspended. Do not pay money or give documents.'
                            : a.isExpired
                                ? 'License කාලය ඉවරයි. ගෙවීමට පෙර hotline 1989 අමතන්න.\n'
                                    'The license date has passed. Confirm with 1989 first.'
                                : 'Found in the licensed agency list.',
                    style: TextStyle(color: color, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 4, children: [
                  if (a.isRegistered)
                    for (final p in a.phones.take(4))
                      ActionChip(
                        avatar: const Icon(Icons.call, size: 18, color: kNavy),
                        label: Text(p),
                        onPressed: () => _call(p),
                      ),
                  if (a.isRegistered && email != null)
                    ActionChip(
                      avatar: const Icon(Icons.email, size: 18, color: kNavy),
                      label: Text(email),
                      onPressed: () => _mail(email),
                    ),
                  if (hasAddress)
                    ActionChip(
                      avatar:
                          const Icon(Icons.location_on, size: 18, color: kNavy),
                      label: const Text('Map'),
                      onPressed: () => _map(a.address!),
                    ),
                  ActionChip(
                    avatar: const Icon(Icons.share, size: 18, color: kNavy),
                    label: const Text('Share'),
                    onPressed: () => _share(a),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show the home view until the user has searched
    final showHome = !_searched && !_loading && _error == null;

    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          _header(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _searchBox(),
                const SizedBox(height: 16),

                // Loading and error messages
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(_error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red)),
                  ),

                // Nothing found message
                if (_searched &&
                    !_loading &&
                    _error == null &&
                    _results.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Not found in the lists we have. '
                      'Please confirm with hotline 1989 before paying.',
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Search results
                if (_searched && !_loading)
                  for (final a in _results) _buildCard(a),

                // Home view: tips, status cards and recent searches
                if (showHome) ...[
                  _quickTips(),
                  const SizedBox(height: 16),
                  _statusRow(),
                  const SizedBox(height: 20),
                  _recentSection(),
                ],

                const SizedBox(height: 6),
                _noteBox(),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}