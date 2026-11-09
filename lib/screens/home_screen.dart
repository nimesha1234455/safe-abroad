import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';
import 'checker_screen.dart';
import 'sos_screen.dart';
import 'travel_tips_screen.dart';
import 'saved_screen.dart';
import 'checklist_screen.dart';
import 'embassy_screen.dart';
import 'more_screen.dart';
import 'country_guide_screen.dart'; // country guide page
import 'journey_screen.dart'; // NEW
import 'worker_rights_screen.dart'; // NEW
import 'account_screen.dart'; // My Account

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _shadow = [Shadow(color: Colors.black45, blurRadius: 6)];

  Future<void> _call(String number) async {
    await launchUrl(Uri(scheme: 'tel', path: number));
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  // Report a fake agency: tells the user to call the hotline
  void _reportFake(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Report a fake agency'),
        content: const Text(
            'To report a fake or unlicensed agency, call hotline 1989 and '
            'give the agency name and license number (if any).'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton.icon(
            icon: const Icon(Icons.call),
            label: const Text('Call 1989'),
            onPressed: () {
              Navigator.pop(ctx);
              _call('1989');
            },
          ),
        ],
      ),
    );
  }

  // Top picture with the welcome text
  Widget _header() {
    return SizedBox(
      height: 320,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/header.jpg',
              fit: BoxFit.cover, alignment: Alignment.topCenter),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 50,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00EAF3FF), kBg],
                ),
              ),
            ),
          ),
          const SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hello,',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            shadows: _shadow)),
                    Text('Welcome to Safe Abroad!',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: _shadow)),
                    Text('Your Safety, Our Priority',
                        style: TextStyle(
                            color: Color(0xFFFFE082),
                            fontWeight: FontWeight.w600,
                            shadows: _shadow)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Menu tile with a colored circle icon and a soft tint
  Widget _menuTile({
    required IconData icon,
    required Color color,
    required Color tint,
    required String title,
    required String sub,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, tint],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: tint),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(15),
                blurRadius: 6,
                offset: const Offset(0, 3)),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: color,
                    child: Icon(icon, color: Colors.white, size: 22),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right, color: color),
                ]),
                const SizedBox(height: 6),
                Text(title,
                    maxLines: 2,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: kNavy)),
                Text(sub,
                    style: const TextStyle(fontSize: 11, color: Colors.black54)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Quick Access row
  Widget _quickAccess(BuildContext context) {
    Widget item(IconData icon, Color color, String label, VoidCallback onTap) {
      return Expanded(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 6),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: kNavy)),
            ]),
          ),
        ),
      );
    }

    Widget divider() =>
        Container(width: 1, height: 50, color: Colors.black12);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(14, 6, 24, 6),
          decoration: const BoxDecoration(
            color: kNavy,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14), topRight: Radius.circular(14)),
          ),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.star, color: Colors.white, size: 18),
            SizedBox(width: 6),
            Text('Quick Access',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
          ]),
        ),
        Card(
          margin: EdgeInsets.zero,
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16)),
          ),
          child: Row(children: [
            item(Icons.flight, kBlue, 'Travel\nTips',
                () => _open(context, const TravelTipsScreen())),
            divider(),
            item(Icons.warning_amber_rounded, kRed, 'Report\nFake Agency',
                () => _reportFake(context)),
          ]),
        ),
      ],
    );
  }

  Widget _navItem(
      IconData icon, String label, bool selected, VoidCallback onTap) {
    final c = selected ? kGold : Colors.white;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: c),
              Text(label, style: TextStyle(color: c, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _header(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  GridView.count(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.35,
                    children: [
                      _menuTile(
                        icon: Icons.search,
                        color: kBlue,
                        tint: const Color(0xFFD6E6FB),
                        title: 'Agency Checker',
                        sub: 'Check agency license',
                        onTap: () => _open(context, const CheckerScreen()),
                      ),
                      _menuTile(
                        icon: Icons.public,
                        color: kGreen,
                        tint: const Color(0xFFD4F0DC),
                        title: 'Country Guide',
                        sub: 'Jobs & salary info',
                        onTap: () =>
                            _open(context, const CountryGuideScreen()),
                      ),
                      _menuTile(
                        icon: Icons.fact_check,
                        color: Colors.deepPurple,
                        tint: const Color(0xFFE3DAF7),
                        title: 'Document Checklist',
                        sub: 'Prepare right',
                        onTap: () => _open(context, const ChecklistScreen()),
                      ),
                      _menuTile(
                        icon: Icons.sos,
                        color: kRed,
                        tint: const Color(0xFFFAD4D4),
                        title: 'Emergency SOS',
                        sub: 'Get help fast',
                        onTap: () => _open(context, const SosScreen()),
                      ),
                      _menuTile(
                        icon: Icons.call,
                        color: const Color(0xFF1565C0),
                        tint: const Color(0xFFD3E4F8),
                        title: 'Hotline 1989',
                        sub: 'Call now',
                        onTap: () => _call('1989'),
                      ),
                      _menuTile(
                        icon: Icons.account_balance,
                        color: Colors.teal,
                        tint: const Color(0xFFD2F0EE),
                        title: 'Embassy Contacts',
                        sub: 'Get contact info',
                        onTap: () => _open(context, const EmbassyScreen()),
                      ),
                      // ---- NEW tiles ----
                      _menuTile(
                        icon: Icons.route,
                        color: Colors.indigo,
                        tint: const Color(0xFFDDE1F7),
                        title: 'My Journey',
                        sub: 'Track each step',
                        onTap: () => _open(context, const JourneyScreen()),
                      ),
                      _menuTile(
                        icon: Icons.gavel,
                        color: Colors.brown,
                        tint: const Color(0xFFEADBD2),
                        title: 'Worker Rights',
                        sub: 'Know your rights',
                        onTap: () =>
                            _open(context, const WorkerRightsScreen()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _quickAccess(context),
                  const SizedBox(height: 12),
                  const Text(
                    'Personal app, not a government app. Data is from the '
                    'public licensed agency list. Always confirm with '
                    'hotline 1989.',
                    style: TextStyle(fontSize: 11, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Round search button in the middle of the bottom bar
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: kBlue,
        onPressed: () => _open(context, const CheckerScreen()),
        child: const Icon(Icons.search, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: kNavy,
        surfaceTintColor: Colors.transparent,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              _navItem(Icons.home, 'Home', true, () {}),
              _navItem(Icons.bookmark, 'Saved', false,
                  () => _open(context, const SavedScreen())),
              const SizedBox(width: 72),
              _navItem(Icons.person, 'Account', false,
                  () => _open(context, const AccountScreen())),
              _navItem(Icons.more_horiz, 'More', false,
                  () => _open(context, const MoreScreen())),
            ],
          ),
        ),
      ),
    );
  }
}