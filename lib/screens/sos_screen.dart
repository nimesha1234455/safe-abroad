import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';
import 'design_widgets.dart';
import 'embassy_screen.dart';
// Screen to share my location with family
import 'share_location_screen.dart';
// Ready-made emergency sentences (offline)
import 'safe_message_screen.dart';

// SLBFE hotline number
const _hotline = '1989';

// Safety tips shown in the bottom sheet
const _safetyTips = <String>[
  'Share your address and employer details with family back home.',
  'Keep photocopies and phone photos of your passport, visa and contract.',
  'Save the embassy and hotline numbers in your phone.',
  'Do not sign a contract you do not understand.',
  'If you feel unsafe, call the hotline or your embassy straight away.',
];

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});
  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> with SingleTickerProviderStateMixin {
  // Animation for the pulsing SOS button
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  // Open Google Maps to find the nearest embassy
  Future<void> _findEmbassy() async {
    try {
      await launchUrl(
        Uri.parse('https://www.google.com/maps/search/?api=1&query=Sri+Lanka+embassy+near+me'),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {}
  }

  // Open the screen that shares my location with family
  void _shareLocation() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ShareLocationScreen()),
    );
  }

  // Open the Safe Message screen
  void _safeMessage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SafeMessageScreen()),
    );
  }

  // Show safety tips in a bottom sheet
  void _tips() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 24), shrinkWrap: true, children: [
        const Text('Safety Tips', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kNavy)),
        for (final t in _safetyTips) ListTile(leading: const Icon(Icons.shield_outlined, color: kBlue), title: Text(t)),
      ]),
    );
  }

  // One action button (icon + label)
  Widget _action(IconData icon, Color color, String label, VoidCallback onTap) {
    return Expanded(
      child: Material(
        color: const Color(0xFFE8F0FF),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 6),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(color: kNavy, fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientScreen(
      title: 'Emergency SOS',
      trailingIcon: Icons.notifications_active,
      colors: const [Color(0xFF9E1B1B), kRed],
      sheetColor: Colors.white,
      hero: const SizedBox(height: 16),
      // Bottom support banner
      footer: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [kBlue, kNavy], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: const SafeArea(
          top: false,
          child: Row(children: [
            Icon(Icons.verified_user, color: kGreen, size: 42),
            SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('You are not alone.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              Text('We are here to support you.', style: TextStyle(color: Colors.white)),
            ]),
          ]),
        ),
      ),
      children: [
        // Big SOS button (calls the hotline)
        Center(
          child: Semantics(
            button: true,
            label: 'SOS. Call hotline $_hotline',
            child: AnimatedBuilder(
              animation: _c,
              builder: (_, __) => Transform.scale(
                scale: 1 + 0.05 * _c.value,
                child: GestureDetector(
                  onTap: () => dial(_hotline),
                  child: Container(
                    width: 230,
                    height: 230,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFDE3E1),
                      boxShadow: [BoxShadow(color: kRed.withAlpha(60), blurRadius: 30, spreadRadius: 6)],
                    ),
                    child: Container(
                      width: 184,
                      height: 184,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [Color(0xFFE8463A), Color(0xFFC62020)]),
                      ),
                      child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.call, color: Colors.white, size: 52),
                        Text('SOS', style: TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w800)),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Center(child: Text('Need Help?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: kNavy))),
        const Center(child: Text('Tap the button for immediate help')),
        const SizedBox(height: 14),
        // Red info box
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFFDE3E1), borderRadius: BorderRadius.circular(16)),
          child: const Row(children: [
            Icon(Icons.error, color: kRed),
            SizedBox(width: 10),
            Expanded(child: Text('This will connect you to SLBFE Emergency Hotline ($_hotline)', style: TextStyle(color: kNavy, fontWeight: FontWeight.w500))),
          ]),
        ),
        const SizedBox(height: 14),
        // Row 1: hotline and embassy contacts
        Row(children: [
          _action(Icons.call, kBlue, 'SLBFE\nHotline', () => dial(_hotline)),
          const SizedBox(width: 12),
          _action(Icons.account_balance, kBlue, 'Embassy\nContacts', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmbassyScreen()))),
        ]),
        const SizedBox(height: 12),
        // Row 2: nearest embassy and safety tips
        Row(children: [
          _action(Icons.location_on, kRed, 'Find Nearest\nEmbassy', _findEmbassy),
          const SizedBox(width: 12),
          _action(Icons.shield, kBlue, 'Safety\nTips', _tips),
        ]),
        const SizedBox(height: 12),
        // Row 3: share my location and safe message
        Row(children: [
          _action(Icons.share_location, kRed, 'Share My Location\nwith Family', _shareLocation),
          const SizedBox(width: 12),
          _action(Icons.record_voice_over, kBlue, 'Safe\nMessage', _safeMessage),
        ]),
        const SizedBox(height: 16),
      ],
    );
  }
}