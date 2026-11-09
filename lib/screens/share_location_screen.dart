import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/family_store.dart';
import '../services/location_service.dart';
import '../theme.dart';
import 'family_contacts_screen.dart';

// Screen to share my location with family
class ShareLocationScreen extends StatefulWidget {
  const ShareLocationScreen({super.key});

  @override
  State<ShareLocationScreen> createState() => _ShareLocationScreenState();
}

class _ShareLocationScreenState extends State<ShareLocationScreen> {
  Position? _pos;
  DateTime? _updatedAt;
  bool _loading = false;
  String? _error;
  List<FamilyContact> _contacts = [];

  // Colors for the round contact pictures
  static const List<Color> _avatarColors = [
    Color(0xFFE8638A),
    Color(0xFF3F7DF0),
    Color(0xFF2FAE66),
    Color(0xFFF2A33A),
    Color(0xFF8E5CF0),
  ];

  // WhatsApp green
  static const Color _waGreen = Color(0xFF1FAF5A);

  // Your app package name (applicationId in android/app/build.gradle).
  // OpenStreetMap asks apps to say who they are.
  static const String _packageName = 'com.example.agency_checker_lk';

  @override
  void initState() {
    super.initState();
    _loadContacts();
    // Get the location as soon as the screen opens (it is an emergency)
    _getLocation();
  }

  // Load saved family contacts
  Future<void> _loadContacts() async {
    final data = await FamilyStore.load();
    if (!mounted) return;
    setState(() => _contacts = data);
  }

  // Get my location
  Future<void> _getLocation() async {
    setState(() {
      _loading = true;
      _error = null;
      _pos = null; // hide the old location while we find a new one
    });
    try {
      final p = await LocationService.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _pos = p;
        _updatedAt = DateTime.now();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is String ? e : 'Could not get your location. Try again.';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Text like "Today, 9:41 AM"
  String _timeText() {
    final t = _updatedAt ?? DateTime.now();
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    final ampm = t.hour < 12 ? 'AM' : 'PM';
    return 'Today, $h:$m $ampm';
  }

  // The message that will be sent
  String _message() {
    return 'I need help. My location: ${LocationService.mapLink(_pos!)}\n'
        '(Sent from Agency Checker LK)';
  }

  // Show a small message
  void _msg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  // Open another app (WhatsApp, SMS or Maps)
  Future<void> _open(Uri uri) async {
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) _msg('Could not open the app.');
    } catch (e) {
      _msg('Could not open the app.');
    }
  }

  // Open my location in the Maps app (tap on the small map)
  void _openInMaps() {
    if (_pos == null) return;
    _open(Uri.parse(LocationService.mapLink(_pos!)));
  }

  // Send by WhatsApp to a saved contact
  void _whatsapp(FamilyContact c) {
    final number = FamilyStore.intlNumber(c.phone);
    final text = Uri.encodeComponent(_message());
    _open(Uri.parse('https://wa.me/$number?text=$text'));
  }

  // Send by WhatsApp, choose the person inside WhatsApp
  void _whatsappChoose() {
    final text = Uri.encodeComponent(_message());
    _open(Uri.parse('https://wa.me/?text=$text'));
  }

  // Send by SMS to a saved contact
  void _sms(FamilyContact c) {
    final number = c.phone.replaceAll(' ', '');
    final text = Uri.encodeComponent(_message());
    _open(Uri.parse('sms:$number?body=$text'));
  }

  // Copy the message so it can be pasted anywhere
  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _message()));
    _msg('Copied. You can paste it in any app.');
  }

  // Open the contacts screen, then reload
  Future<void> _manageContacts() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FamilyContactsScreen()),
    );
    _loadContacts();
  }

  // White card look (shared by all cards)
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

  // Blue header with back button, title and plane
  Widget _header() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 8,
        16,
        28,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kNavy, kBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
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
                  'Share My Location',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
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
          // Small plane icon
          Transform.rotate(
            angle: 0.785,
            child: const Icon(Icons.flight, color: Colors.white, size: 38),
          ),
        ],
      ),
    );
  }

  // Card shown while the location is being found
  Widget _loadingCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: const Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 12),
          Text(
            'Getting your location...',
            style: TextStyle(color: kNavy, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // Card shown when the location could not be found
  Widget _errorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE3E1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _error!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Try again'),
            onPressed: _getLocation,
          ),
        ],
      ),
    );
  }

  // Small OpenStreetMap map with a pin and an accuracy circle
  // (free, no API key and no card needed)
  Widget _map(Position p) {
    final point = LatLng(p.latitude, p.longitude);
    return FlutterMap(
      // New key = the map is rebuilt when the location changes
      key: ValueKey('${p.latitude},${p.longitude}'),
      options: MapOptions(
        initialCenter: point,
        initialZoom: p.accuracy < 100 ? 16 : 14,
        // The map is only a picture here. Tapping it opens the Maps app.
        interactionOptions:
            const InteractionOptions(flags: InteractiveFlag.none),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: _packageName,
        ),
        // Accuracy circle (radius in meters)
        CircleLayer(
          circles: [
            CircleMarker(
              point: point,
              radius: p.accuracy,
              useRadiusInMeter: true,
              color: kBlue.withAlpha(40),
              borderColor: kBlue,
              borderStrokeWidth: 1,
            ),
          ],
        ),
        // Blue pin (the tip of the pin sits on my location)
        MarkerLayer(
          markers: [
            Marker(
              point: point,
              width: 40,
              height: 40,
              alignment: Alignment.topCenter,
              child: const Icon(Icons.location_on, color: kBlue, size: 40),
            ),
          ],
        ),
        // Credit line required by the OpenStreetMap licence.
        // Top right, so the Refresh button does not cover it.
        const SimpleAttributionWidget(
          source: Text('© OpenStreetMap'),
          backgroundColor: Color(0xCCFFFFFF),
          alignment: Alignment.topRight,
        ),
      ],
    );
  }

  // Big card: "Location Found"
  Widget _locationCard() {
    final p = _pos!;
    return Container(
      height: 196,
      decoration: _cardDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Real map on the right side
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 150,
              child: IgnorePointer(child: _map(p)),
            ),
            // Fade from white into the map
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 150,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Colors.white, Colors.white.withAlpha(0)],
                      stops: const [0.0, 0.55],
                    ),
                  ),
                ),
              ),
            ),
            // Tap the map area to open the Maps app
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 150,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _openInMaps,
              ),
            ),

            // Text part
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Blue arrow box
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: kBlue,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.navigation,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Location Found',
                              style: TextStyle(
                                color: kNavy,
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.my_location,
                                  size: 16,
                                  color: kNavy,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${p.latitude.toStringAsFixed(5)}, '
                                  '${p.longitude.toStringAsFixed(5)}',
                                  style: const TextStyle(
                                    color: kNavy,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Green accuracy pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: kGreen.withAlpha(40),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.gps_fixed,
                                    size: 14,
                                    color: Color(0xFF1B7F3B),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Accuracy: about ${p.accuracy.toStringAsFixed(0)} m',
                                    style: const TextStyle(
                                      color: Color(0xFF1B7F3B),
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
                  const Spacer(),
                  // Line (stops before the map)
                  Padding(
                    padding: const EdgeInsets.only(right: 130),
                    child: Divider(height: 1, color: kNavy.withAlpha(30)),
                  ),
                  const SizedBox(height: 8),
                  // Last updated time
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: kBlue.withAlpha(25),
                        ),
                        child: const Icon(
                          Icons.access_time,
                          size: 20,
                          color: kNavy,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Last Updated',
                            style: TextStyle(
                              color: kNavy,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            _timeText(),
                            style: const TextStyle(
                              color: kNavy,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Refresh button
            Positioned(
              right: 12,
              bottom: 12,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: kNavy,
                  shape: const StadiumBorder(),
                  side: BorderSide(color: kBlue.withAlpha(90)),
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'),
                onPressed: _getLocation,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Title: "Send to Family"
  Widget _sectionTitle() {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: kBlue.withAlpha(25),
          ),
          child: const Icon(Icons.people, color: kBlue, size: 26),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Send to Family',
                style: TextStyle(
                  color: kNavy,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Choose who to share your location with',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Small square button with a caption (WhatsApp or SMS)
  Widget _sendButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withAlpha(35),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 25),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // One family contact card
  Widget _contactCard(int i, FamilyContact c) {
    final color = _avatarColors[i % _avatarColors.length];
    final initial = c.name.isEmpty ? '?' : c.name.substring(0, 1).toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          // Round picture with the first letter
          CircleAvatar(
            radius: 22,
            backgroundColor: color,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Name and phone
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: kNavy,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 14, color: kBlue),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        c.phone,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: kNavy, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          // WhatsApp and SMS buttons
          _sendButton(
            icon: Icons.chat,
            color: _waGreen,
            label: 'WhatsApp',
            onTap: () => _whatsapp(c),
          ),
          const SizedBox(width: 6),
          _sendButton(
            icon: Icons.sms,
            color: kBlue,
            label: 'SMS',
            onTap: () => _sms(c),
          ),
        ],
      ),
    );
  }

  // Banner: WhatsApp (choose a person)
  Widget _whatsappBanner() {
    return Material(
      color: const Color(0xFFDCE8FF),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: _whatsappChoose,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _waGreen,
                ),
                child: const Icon(Icons.chat, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WhatsApp',
                      style: TextStyle(
                        color: kNavy,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Choose a person from WhatsApp',
                      style: TextStyle(color: kNavy, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: kNavy, size: 28),
            ],
          ),
        ),
      ),
    );
  }

  // Big blue button: Copy Message
  Widget _copyButton() {
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
          onTap: _copy,
          child: const SizedBox(
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.copy, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  'Copy Message',
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

  // White outlined button: Family Contacts
  Widget _contactsButton() {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: kNavy,
        minimumSize: const Size.fromHeight(54),
        shape: const StadiumBorder(),
        side: BorderSide(color: kBlue.withAlpha(90), width: 1.5),
      ),
      icon: const Icon(Icons.people),
      label: const Text(
        'Family Contacts',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
      ),
      onPressed: _manageContacts,
    );
  }

  // Note box at the bottom
  Widget _noteBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFDCE8FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user, color: kGreen, size: 44),
          Container(
            width: 1,
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: kNavy.withAlpha(40),
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Important Note',
                  style: TextStyle(
                    color: kBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Your location is sent only when you press a send button. '
                  'It is not tracked in the background. A GPS signal is '
                  'needed, and WhatsApp needs internet.',
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
      backgroundColor: const Color(0xFFEFF4FF),
      body: Column(
        children: [
          _header(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                // Location status: loading, error or found
                if (_loading) _loadingCard(),
                if (!_loading && _error != null) _errorCard(),
                if (!_loading && _pos != null) _locationCard(),

                // Send section (only when the location is found)
                if (_pos != null) ...[
                  const SizedBox(height: 20),
                  _sectionTitle(),
                  const SizedBox(height: 12),

                  for (int i = 0; i < _contacts.length; i++)
                    _contactCard(i, _contacts[i]),

                  if (_contacts.isEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: _cardDecoration(),
                      child: const Text(
                        'No family contacts saved yet. '
                        'Tap "Family Contacts" below to add one.',
                        style: TextStyle(color: kNavy),
                      ),
                    ),

                  _whatsappBanner(),
                  const SizedBox(height: 14),
                  _copyButton(),
                ],

                const SizedBox(height: 14),
                _contactsButton(),
                const SizedBox(height: 14),
                _noteBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}