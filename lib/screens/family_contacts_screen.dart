import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/family_store.dart';
import '../theme.dart';
import 'share_location_screen.dart';

// Screen to add, edit, call, message and remove family contacts
class FamilyContactsScreen extends StatefulWidget {
  const FamilyContactsScreen({super.key});

  @override
  State<FamilyContactsScreen> createState() => _FamilyContactsScreenState();
}

class _FamilyContactsScreenState extends State<FamilyContactsScreen> {
  static const int _maxContacts = 5;
  static const Color _pageBg = Color(0xFFEFF4FF);

  // Colors for the round contact pictures
  static const List<Color> _avatarColors = [
    Color(0xFFE8638A),
    Color(0xFF3F7DF0),
    Color(0xFF2FAE66),
    Color(0xFFF2A33A),
    Color(0xFF8E5CF0),
  ];

  List<FamilyContact> _contacts = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  // Load saved contacts
  Future<void> _load() async {
    final data = await FamilyStore.load();
    if (!mounted) return;
    setState(() => _contacts = data);
  }

  // Show a small message
  void _msg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  // Open the phone app or the SMS app
  Future<void> _launch(Uri uri) async {
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) _msg('Could not open the app.');
    } catch (_) {
      _msg('Could not open the app.');
    }
  }

  void _call(FamilyContact c) =>
      _launch(Uri(scheme: 'tel', path: c.phone.replaceAll(' ', '')));

  void _sms(FamilyContact c) =>
      _launch(Uri(scheme: 'sms', path: c.phone.replaceAll(' ', '')));

  // Open the form to add a new contact, or edit one
  Future<void> _openForm({int? editIndex}) async {
    if (editIndex == null && _contacts.length >= _maxContacts) {
      _msg('You can save up to $_maxContacts contacts.');
      return;
    }
    final result = await showModalBottomSheet<FamilyContact>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ContactForm(
        initial: editIndex == null ? null : _contacts[editIndex],
      ),
    );
    if (result == null) return;
    if (editIndex == null) {
      _contacts.add(result);
    } else {
      _contacts[editIndex] = result;
    }
    await FamilyStore.save(_contacts);
    if (!mounted) return;
    setState(() {});
  }

  // Ask before removing a contact
  Future<void> _confirmRemove(int index) async {
    final c = _contacts[index];
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete contact?'),
        content: Text('Remove ${c.name} from your family contacts?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (yes != true) return;
    _contacts.removeAt(index);
    await FamilyStore.save(_contacts);
    if (!mounted) return;
    setState(() {});
  }

  // White card look
  BoxDecoration _cardDecoration() {
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

  // Blue wavy header
  Widget _header() {
    return ClipPath(
      clipper: _WaveClipper(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          16,
          MediaQuery.of(context).padding.top + 10,
          16,
          46,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kNavy, kBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            // Round back button
            InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 48,
                height: 48,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Family Contacts',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Keep your family informed & safe',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.groups, color: Colors.white, size: 44),
          ],
        ),
      ),
    );
  }

  // Card: "Share Your Location" (opens the share screen)
  Widget _shareCard() {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: _cardDecoration(),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ShareLocationScreen()),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Shield with a people icon
                const SizedBox(
                  width: 64,
                  height: 72,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.shield, size: 72, color: kNavy),
                      Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Icon(Icons.groups, size: 32, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 64,
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                  color: kNavy.withAlpha(40),
                ),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Share Your Location',
                        style: TextStyle(
                          color: kNavy,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Send your location to your family when you need to.',
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: kBlue,
                  ),
                  child: const Icon(Icons.near_me, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Dashed box: "Add Contact"
  Widget _addBox() {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _openForm(),
      child: CustomPaint(
        painter: _DashedBorderPainter(color: kBlue.withAlpha(140)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
          child: Row(
            children: [
              const Spacer(),
              Column(
                children: [
                  const Icon(Icons.person_add_alt_1, color: kBlue, size: 40),
                  const SizedBox(height: 6),
                  const Text(
                    'Add Contact',
                    style: TextStyle(
                      color: kNavy,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    _contacts.length >= _maxContacts
                        ? 'You have reached the limit of $_maxContacts'
                        : "Save a family member's contact",
                    style: const TextStyle(color: Colors.black87, fontSize: 13),
                  ),
                ],
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kBlue.withAlpha(30),
                    ),
                    child: const Icon(Icons.chevron_right, color: kNavy),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Row title: "Your Family Contacts" and the count
  Widget _listTitle() {
    return Row(
      children: [
        const Icon(Icons.groups, color: kBlue, size: 32),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Your Family Contacts',
            style: TextStyle(
              color: kNavy,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: kBlue.withAlpha(30),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${_contacts.length} Contact${_contacts.length == 1 ? '' : 's'}',
            style: const TextStyle(
              color: kBlue,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  // Small round action button (call or message)
  Widget _roundAction(IconData icon, VoidCallback onTap) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: kBlue.withAlpha(28),
          border: Border.all(color: kBlue.withAlpha(60)),
        ),
        child: Icon(icon, color: kBlue, size: 21),
      ),
    );
  }

  // One family contact card
  Widget _contactCard(int i, FamilyContact c) {
    final color = _avatarColors[i % _avatarColors.length];
    final initial = c.name.isEmpty ? '?' : c.name.substring(0, 1).toUpperCase();
    final isParent = c.relation == 'Mother' || c.relation == 'Father';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: _cardDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Blue strip on the left
              Container(width: 5, color: kBlue),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
                  child: Row(
                    children: [
                      // Round picture with the first letter and a small badge
                      SizedBox(
                        width: 70,
                        height: 70,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 33,
                              backgroundColor: color,
                              child: Text(
                                initial,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: kBlue,
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                ),
                                child: Icon(
                                  isParent ? Icons.home : Icons.person,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Name, phone and relation
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: kNavy,
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.phone, size: 15, color: kBlue),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    c.phone,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: kNavy,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: kBlue.withAlpha(30),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                c.relation,
                                style: const TextStyle(
                                  color: kNavy,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      _roundAction(Icons.call, () => _call(c)),
                      const SizedBox(width: 6),
                      _roundAction(Icons.sms, () => _sms(c)),
                      // Menu: Edit / Delete
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: kNavy),
                        padding: EdgeInsets.zero,
                        onSelected: (v) {
                          if (v == 'edit') _openForm(editIndex: i);
                          if (v == 'delete') _confirmRemove(i);
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Shown when there are no contacts yet
  Widget _emptyBox() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: const Text(
        'No contacts yet. Tap "Add Contact" to save your first family member.',
        style: TextStyle(color: kNavy, fontSize: 14),
      ),
    );
  }

  // Note box
  Widget _noteBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFDCE8FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBlue.withAlpha(40)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: kNavy,
            ),
            child: const Icon(Icons.info_outline, color: Colors.white),
          ),
          Container(
            width: 1,
            height: 56,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: kNavy.withAlpha(60),
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Important Note',
                  style: TextStyle(
                    color: kBlue,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Keep your family contacts updated. They are saved only on '
                  'your phone. In case of emergency, this information can '
                  'help you.',
                  style: TextStyle(color: kNavy, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Skyline picture with the tagline at the bottom
  Widget _skyline() {
    return SizedBox(
      height: 150,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _SkylinePainter())),
          const Positioned(
            right: 16,
            bottom: 34,
            child: Text(
              'Safe Abroad\nPilliwelata',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: kNavy,
                fontSize: 20,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
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
      body: Column(
        children: [
          _header(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: Column(
                    children: [
                      _shareCard(),
                      const SizedBox(height: 18),
                      _addBox(),
                      const SizedBox(height: 22),
                      _listTitle(),
                      const SizedBox(height: 12),
                      if (_contacts.isEmpty) _emptyBox(),
                      for (int i = 0; i < _contacts.length; i++)
                        _contactCard(i, _contacts[i]),
                      const SizedBox(height: 6),
                      _noteBox(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                _skyline(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Form shown in the bottom sheet (add or edit)
class _ContactForm extends StatefulWidget {
  final FamilyContact? initial;
  const _ContactForm({this.initial});

  @override
  State<_ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<_ContactForm> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late String _relation;
  String? _error;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initial?.name ?? '');
    _phone = TextEditingController(text: widget.initial?.phone ?? '');
    _relation = widget.initial?.relation ?? 'Mother';
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim().replaceAll('|', ' ');
    final phone = _phone.text.trim().replaceAll('|', '');
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (name.isEmpty || digits.length < 9) {
      setState(() => _error = 'Enter a name and a valid phone number.');
      return;
    }
    Navigator.pop(context, FamilyContact(name, phone, _relation));
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.initial != null;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              editing ? 'Edit Contact' : 'Add Contact',
              style: const TextStyle(
                color: kNavy,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Name (example: Amma)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone (example: 0771234567)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Relation',
              style: TextStyle(color: kNavy, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final r in FamilyStore.relations)
                  ChoiceChip(
                    label: Text(r),
                    selected: _relation == r,
                    onSelected: (_) => setState(() => _relation = r),
                  ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: kNavy,
                  minimumSize: const Size.fromHeight(50),
                  shape: const StadiumBorder(),
                ),
                onPressed: _save,
                child: Text(
                  editing ? 'Save changes' : 'Save contact',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
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

// Dashed rounded border for the "Add Contact" box
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(20),
        ),
      );
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + 6), paint);
        d += 11;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) => old.color != color;
}

// Simple drawn city skyline with blue waves at the bottom
class _SkylinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final base = h - 40; // ground line of the buildings

    final b1 = Paint()..color = kBlue.withAlpha(170);
    final b2 = Paint()..color = kNavy.withAlpha(200);

    // Buildings (x as a fraction of the width, width, height)
    void building(double x, double bw, double bh, Paint p) {
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(w * x, base - bh, bw, bh),
          topLeft: const Radius.circular(3),
          topRight: const Radius.circular(3),
        ),
        p,
      );
    }

    // Tower with a pointed top
    void tower(double x, double bh, Paint p) {
      canvas.drawRect(Rect.fromLTWH(w * x, base - bh, 8, bh), p);
      final tip = Path()
        ..moveTo(w * x - 4, base - bh)
        ..lineTo(w * x + 4, base - bh - 30)
        ..lineTo(w * x + 12, base - bh)
        ..close();
      canvas.drawPath(tip, p);
    }

    building(0.02, 26, 44, b1);
    building(0.08, 22, 60, b2);
    tower(0.15, 52, b2);
    building(0.2, 34, 36, b1);
    // Dome
    canvas.drawCircle(Offset(w * 0.32, base - 34), 20, b1);
    building(0.3, 40, 34, b1);
    tower(0.42, 70, b2);
    building(0.48, 28, 50, b1);
    building(0.54, 24, 66, b2);
    building(0.6, 30, 40, b1);
    tower(0.69, 46, b1);
    building(0.76, 26, 56, b2);
    building(0.82, 34, 34, b1);
    building(0.9, 24, 48, b2);

    // Blue wave at the bottom
    final wave = Path()
      ..moveTo(0, h - 26)
      ..quadraticBezierTo(w * 0.3, h - 58, w * 0.6, h - 30)
      ..quadraticBezierTo(w * 0.85, h - 12, w, h - 40)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      wave,
      Paint()
        ..shader = const LinearGradient(colors: [kBlue, kNavy])
            .createShader(Rect.fromLTWH(0, h - 60, w, 60)),
    );

    // Thin gold line along the wave
    final gold = Path()
      ..moveTo(0, h - 22)
      ..quadraticBezierTo(w * 0.3, h - 54, w * 0.6, h - 26)
      ..quadraticBezierTo(w * 0.85, h - 8, w, h - 36);
    canvas.drawPath(
      gold,
      Paint()
        ..color = const Color(0xFFFFC107)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}