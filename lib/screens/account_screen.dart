import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/saved_service.dart';
import '../theme.dart';
import 'checklist_screen.dart';
import 'embassy_screen.dart';
import 'login_screen.dart';
import 'saved_screen.dart';

// My Account: a profile that stays on this phone.
// (Only the login phone number is sent to the server, to send the SMS code.)
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  static const _pageBg = Color(0xFFEFF4FF);
  static const _fieldBg = Color(0xFFF4F7FD);

  static const _countries = [
    'Not decided', 'UAE', 'Qatar', 'Kuwait', 'Saudi Arabia', 'Oman',
    'Bahrain', 'Jordan', 'Israel', 'Japan', 'South Korea', 'Malaysia',
    'Singapore', 'Maldives', 'Romania', 'Cyprus', 'Other',
  ];

  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _emName = TextEditingController();
  final _emPhone = TextEditingController();
  String _country = 'Not decided';
  String? _loginPhone; // phone used to log in (null = guest)
  bool _verified = false; // true if the user logged in with an SMS code
  int _saved = 0;
  int _ticked = 0;
  int _contacts = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _emName.dispose();
    _emPhone.dispose();
    super.dispose();
  }

  // 0772847354 or 772847354 -> +94772847354
  String _formatPhone(String d) {
    var x = d.replaceAll(RegExp(r'[^0-9]'), '');
    if (x.startsWith('0')) x = x.substring(1);
    return '+94$x';
  }

  Future<void> _loadProfile() async {
    final p = await SharedPreferences.getInstance();
    // Read the login info straight from the saved settings
    final login = p.getString('auth_phone');
    final hasToken = p.getString('auth_token') != null;
    if (!mounted) return;
    setState(() {
      _loginPhone = login;
      _verified = login != null || hasToken;
      _name.text = p.getString('profile_name') ?? '';
      _phone.text = p.getString('profile_phone') ?? '';
      // First time: fill the phone box with the number used to log in
      if (_phone.text.isEmpty && login != null && login.isNotEmpty) {
        _phone.text = _formatPhone(login);
      }
      _email.text = p.getString('profile_email') ?? '';
      _emName.text = p.getString('profile_em_name') ?? '';
      _emPhone.text = p.getString('profile_em_phone') ?? '';
      final c = p.getString('profile_country');
      _country = _countries.contains(c) ? c! : 'Not decided';
    });
    await _loadCounts();
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _loadCounts() async {
    final p = await SharedPreferences.getInstance();
    final saved = await SavedService.load();
    if (!mounted) return;
    setState(() {
      _saved = saved.length;
      _ticked = (p.getStringList('checklist_done') ?? []).length;
      _contacts = (p.getStringList('my_contacts') ?? []).length;
    });
  }

  Future<void> _saveProfile() async {
    FocusScope.of(context).unfocus();
    final p = await SharedPreferences.getInstance();
    await p.setString('profile_name', _name.text.trim());
    await p.setString('profile_phone', _phone.text.trim());
    await p.setString('profile_email', _email.text.trim());
    await p.setString('profile_em_name', _emName.text.trim());
    await p.setString('profile_em_phone', _emPhone.text.trim());
    await p.setString('profile_country', _country);
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Saved on this phone')));
  }

  // Log out and go back to the login screen
  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (r) => false,
    );
  }

  Future<void> _deleteAll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete all my data?'),
        content: const Text(
            'This removes your profile, saved agencies, checklist ticks and '
            'contacts from this phone, and logs you out. It cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: kRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final p = await SharedPreferences.getInstance();
    await p.clear();
    if (!mounted) return;
    setState(() {
      _name.clear();
      _phone.clear();
      _email.clear();
      _emName.clear();
      _emPhone.clear();
      _country = 'Not decided';
      _loginPhone = null;
      _verified = false;
      _saved = 0;
      _ticked = 0;
      _contacts = 0;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('All data deleted')));
  }

  Future<void> _go(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    _loadCounts();
  }

  // ---------- looks ----------

  BoxDecoration _card() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: kNavy.withAlpha(25),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  // Blue wavy header with the profile inside
  Widget _header() {
    final name = _name.text.trim();
    final phone = _phone.text.trim();
    final verified = _verified;

    return ClipPath(
      clipper: _WaveClipper(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          16,
          MediaQuery.of(context).padding.top + 8,
          16,
          52,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kNavy, kBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // Back button and title
            Row(
              children: [
                InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withAlpha(30),
                      border: Border.all(color: Colors.white.withAlpha(90)),
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text(
                    'My Account',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Picture and name
            Row(
              children: [
                // Avatar with a gold ring
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: kGold,
                  ),
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white,
                    child: name.isEmpty
                        ? const Icon(Icons.person, size: 40, color: kNavy)
                        : Text(
                            name[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: kNavy,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isEmpty ? 'Guest' : name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        phone.isEmpty ? 'Add your details below' : phone,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      // Status chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: verified
                              ? kGreen.withAlpha(60)
                              : Colors.white.withAlpha(30),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: verified ? kGreen : Colors.white54,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              verified ? Icons.verified : Icons.person_outline,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              verified ? 'Phone verified' : 'Guest mode',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Small card with a number: opens a screen when tapped
  Widget _stat(IconData icon, Color color, int value, String label, Widget screen) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: _card(),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _go(screen),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
              child: Column(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withAlpha(30),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$value',
                    style: const TextStyle(
                      color: kNavy,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Title row of a section card
  Widget _sectionTitle(IconData icon, Color color, String title, String sub) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withAlpha(30),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: kNavy,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  sub,
                  style: const TextStyle(color: Colors.black54, fontSize: 12.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Same look for every input box
  InputDecoration _decoration(String label, IconData icon) {
    OutlineInputBorder border(Color c, double w) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c, width: w),
        );
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: kBlue),
      filled: true,
      fillColor: _fieldBg,
      border: border(const Color(0xFFE0E8F5), 1),
      enabledBorder: border(const Color(0xFFE0E8F5), 1),
      focusedBorder: border(kBlue, 1.6),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon,
      {TextInputType? type}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: type,
        onChanged: (_) => setState(() {}),
        decoration: _decoration(label, icon),
      ),
    );
  }

  Widget _countryBox() {
    return InputDecorator(
      decoration: _decoration('Country I want to work in', Icons.flight_takeoff),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          isDense: true,
          value: _country,
          borderRadius: BorderRadius.circular(14),
          items: [
            for (final c in _countries)
              DropdownMenuItem(value: c, child: Text(c)),
          ],
          onChanged: (v) => setState(() => _country = v ?? _country),
        ),
      ),
    );
  }

  // Big blue save button
  Widget _saveButton() {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [kBlue, kNavy]),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: kNavy.withAlpha(60),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: _saveProfile,
          child: const SizedBox(
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _privacyNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFDCE8FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBlue.withAlpha(40)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: kNavy,
            ),
            child: const Icon(Icons.lock_outline, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your privacy',
                  style: TextStyle(
                    color: kBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'The details on this page are stored only on this phone. '
                  'The only thing sent to our server is the mobile number you '
                  'use to log in, so we can send the SMS code. Do not enter '
                  'passport or bank details here.',
                  style: TextStyle(color: kNavy, fontSize: 12.5),
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
    return Scaffold(
      backgroundColor: _pageBg,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _header(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                    children: [
                      // Numbers: saved, checklist, embassy contacts
                      Row(
                        children: [
                          _stat(Icons.bookmark, kBlue, _saved, 'Saved\nagencies',
                              const SavedScreen()),
                          const SizedBox(width: 12),
                          _stat(Icons.fact_check, Colors.deepPurple, _ticked,
                              'Checklist\nticked', const ChecklistScreen()),
                          const SizedBox(width: 12),
                          _stat(Icons.account_balance, Colors.teal, _contacts,
                              'Embassy\ncontacts', const EmbassyScreen()),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // My details
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: _card(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle(Icons.badge, kBlue, 'My details',
                                'Your own information'),
                            _field(_name, 'Full name', Icons.person_outline),
                            _field(_phone, 'Phone number', Icons.phone_outlined,
                                type: TextInputType.phone),
                            _field(_email, 'Email (optional)',
                                Icons.email_outlined,
                                type: TextInputType.emailAddress),
                            _countryBox(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Emergency contact
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: _card(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle(
                                Icons.family_restroom,
                                kRed,
                                'Emergency contact',
                                'A family member to call in an emergency'),
                            _field(_emName, 'Name', Icons.person_outline),
                            _field(_emPhone, 'Phone number', Icons.call_outlined,
                                type: TextInputType.phone),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      _saveButton(),
                      const SizedBox(height: 18),
                      _privacyNote(),
                      const SizedBox(height: 18),

                      // Log out
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kNavy,
                          backgroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(52),
                          shape: const StadiumBorder(),
                          side: BorderSide(color: kBlue.withAlpha(90), width: 1.5),
                        ),
                        onPressed: _logout,
                        icon: const Icon(Icons.logout),
                        label: const Text(
                          'Log out / Switch account',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Delete everything (careful action, so it is quiet)
                      TextButton.icon(
                        style: TextButton.styleFrom(foregroundColor: kRed),
                        onPressed: _deleteAll,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Delete all my data on this phone'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// Wavy bottom edge for the header
class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    return Path()
      ..lineTo(0, h - 26)
      ..quadraticBezierTo(w * 0.25, h + 4, w * 0.5, h - 18)
      ..quadraticBezierTo(w * 0.8, h - 44, w, h - 14)
      ..lineTo(w, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}