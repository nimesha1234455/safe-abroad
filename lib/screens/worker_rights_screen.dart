import 'package:flutter/material.dart';
import '../theme.dart';
import 'design_widgets.dart';

class _Right {
  final String title, sub;
  final IconData icon;
  final Color color, tint;
  final List<String> points;
  const _Right(this.title, this.sub, this.icon, this.color, this.tint, this.points);
}

// General information only. Have it reviewed before release.
const _rights = <_Right>[
  _Right('Your Rights', 'Know your legal rights\nas an overseas worker', Icons.gavel, kOrange, Color(0xFFFFEBD0), [
    'You should get a written contract you understand before you leave.',
    'You should not be asked to pay unofficial fees. Verify the agency licence first.',
    'You can ask for help from your embassy and the SLBFE hotline 1989.',
  ]),
  _Right('Work Contract', 'Understand your contract\nbefore you sign', Icons.description, kBlue, Color(0xFFD9E7FC), [
    'Check the salary, working hours, rest days and contract length.',
    'Make sure the job in the contract is the job you were offered.',
    'Do not sign anything you do not understand.',
    'Keep a paper copy and a photo of the contract.',
  ]),
  _Right('Working Hours', 'Know the working hours\nand overtime rules', Icons.schedule, kOrange, Color(0xFFFFE9C9), [
    'Working hours and rest days should be written in your contract.',
    'Overtime rules differ by country. Ask before you sign.',
    'Keep a record of the hours you work.',
  ]),
  _Right('Safety & Health', 'Your right to a safe workplace', Icons.health_and_safety, kGreen, Color(0xFFD4F0DC), [
    'Your accommodation and workplace should be safe.',
    'Ask for safety equipment and training for risky work.',
    'Know where the nearest hospital is.',
    'Report unsafe conditions to your employer, then to your embassy or the hotline.',
  ]),
  _Right('Complaint Process', 'How to report issues', Icons.headset_mic, Colors.indigo, Color(0xFFE0E3FA), [
    'Keep records: messages, payslips and photos.',
    'If it is safe, talk to your employer or agency first.',
    'Call the SLBFE hotline 1989.',
    'Contact your embassy.',
  ]),
];

class WorkerRightsScreen extends StatelessWidget {
  const WorkerRightsScreen({super.key});

  void _details(BuildContext context, _Right r) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(r.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kNavy)),
          const SizedBox(height: 10),
          for (final p in r.points)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.check_circle, color: kGreen, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(p)),
              ]),
            ),
          const SizedBox(height: 4),
          const Text('General information only, not legal advice. Rules differ by country.',
              style: TextStyle(fontSize: 11, color: Colors.black54)),
        ]),
      ),
    );
  }

  Widget _hero() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 28),
      child: Column(children: [
        SizedBox(
          height: 110,
          child: Stack(alignment: Alignment.center, children: [
            Icon(Icons.shield, size: 120, color: Color(0xFF3C6FE0)),
            Icon(Icons.engineering, size: 54, color: kGold),
          ]),
        ),
        SizedBox(height: 6),
        Text('Know Your Rights', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
        Text('Work Safe, Live Better', style: TextStyle(color: Colors.white, fontSize: 14)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientScreen(
      title: 'Worker Rights',
      trailingIcon: Icons.balance,
      colors: const [kNavy, kBlue],
      hero: _hero(),
      children: [
        for (final r in _rights)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: r.tint,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _details(context, r),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: Icon(r.icon, color: r.color, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(r.title, style: const TextStyle(fontWeight: FontWeight.w700, color: kNavy, fontSize: 15)),
                        Text(r.sub, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      ]),
                    ),
                    const Icon(Icons.chevron_right, color: kBlue),
                  ]),
                ),
              ),
            ),
          ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () => dial('1989'),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFFF3C4), Color(0xFFFFDF8A)]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kGold),
            ),
            child: const Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.warning_amber_rounded, color: kOrange, size: 30),
                SizedBox(width: 8),
                Text('Need Help?', style: TextStyle(color: kNavy, fontWeight: FontWeight.w800, fontSize: 16)),
              ]),
              Text('Call SLBFE Hotline', style: TextStyle(color: kNavy)),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.call, color: kBlue),
                SizedBox(width: 6),
                Text('1989', style: TextStyle(color: kNavy, fontWeight: FontWeight.w800, fontSize: 26)),
              ]),
            ]),
          ),
        ),
      ],
    );
  }
}