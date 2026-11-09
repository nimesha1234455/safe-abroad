import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import 'design_widgets.dart';

const _steps = <_Step>[
  _Step('Find a Job', 'Search & Apply for Jobs', Icons.work, kBlue),
  _Step('Verify Agency', 'Check Authenticity', Icons.verified_user, kGreen),
  _Step('Prepare Documents', 'Passport, Visa, Medical', Icons.description, kBlue),
  _Step('Depart Abroad', 'Your Flight', Icons.flight, kBlue),
  _Step('Settle & Work', 'Start Your Career', Icons.star, kOrange),
];

class _Step {
  final String title, sub;
  final IconData icon;
  final Color color;
  const _Step(this.title, this.sub, this.icon, this.color);
}

class JourneyScreen extends StatefulWidget {
  const JourneyScreen({super.key});
  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen> {
  int current = 0; // steps before this are done

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      if (mounted) setState(() => current = p.getInt('journey_step') ?? 0);
    });
  }

  Future<void> _tap(int i) async {
    setState(() => current = i == current ? i + 1 : i);
    final p = await SharedPreferences.getInstance();
    await p.setInt('journey_step', current);
  }

  Widget _hero() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 10, 24, 28),
      child: Row(children: [
        Icon(Icons.luggage, size: 84, color: Colors.white70),
        SizedBox(width: 14),
        Expanded(
          child: Text('Your Overseas\nJourney Step by Step',
              style: TextStyle(color: Colors.white, fontSize: 24, fontStyle: FontStyle.italic, fontWeight: FontWeight.w700, height: 1.2)),
        ),
      ]),
    );
  }

  Widget _stepRow(int i) {
    final s = _steps[i];
    final done = i < current;
    final isCur = i == current;
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(
          width: 44,
          child: Column(children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kBlue,
                border: Border.all(color: isCur ? kGold : Colors.white, width: 3),
              ),
              child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
            if (i < _steps.length - 1) Expanded(child: Container(width: 3, color: kBlue.withAlpha(110))),
          ]),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: Colors.white,
              elevation: 1,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _tap(i),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(color: s.color.withAlpha(30), borderRadius: BorderRadius.circular(12)),
                      child: Icon(s.icon, color: s.color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(s.title, style: const TextStyle(fontWeight: FontWeight.w700, color: kNavy, fontSize: 15)),
                        Text(s.sub, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      ]),
                    ),
                    Icon(done ? Icons.check_circle : Icons.check_circle_outline,
                        color: done ? kGreen : Colors.grey.shade400),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final complete = current >= _steps.length;
    return GradientScreen(
      title: 'My Journey',
      trailingIcon: Icons.map,
      colors: const [kNavy, Color(0xFF2A5BD7)],
      hero: _hero(),
      children: [
        for (var i = 0; i < _steps.length; i++) _stepRow(i),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFDCEBFF), Color(0xFFBFD8FA)]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(children: [
            const Icon(Icons.emoji_events, color: kOrange, size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(complete ? 'Journey complete!' : 'Dream Big. Work Safe.',
                    style: const TextStyle(color: kNavy, fontWeight: FontWeight.w800, fontSize: 16)),
                const Text('Safe Abroad – Pilliwelata', style: TextStyle(color: kNavy, fontSize: 12)),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text('Tap the current step to mark it done. Tap an earlier step to go back.',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.black54)),
        ),
      ],
    );
  }
}