import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  Widget _card(String title, String text) => Card(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kNavy)),
              const SizedBox(height: 6),
              Text(text),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card('About',
              '$kAppName is a personal app that helps you check a foreign '
              'employment agency before you pay. It is not a government app.'),
          _card('Data',
              'Agency details come from the public licensed agency list. '
              'Lists change, so always confirm with hotline 1989 before '
              'paying anyone.'),
          const SizedBox(height: 4),
          FilledButton.icon(
            icon: const Icon(Icons.call),
            label: const Text('Call hotline 1989'),
            onPressed: () => launchUrl(Uri(scheme: 'tel', path: '1989')),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text('Version 1.0.0',
                style: TextStyle(color: Colors.black54)),
          ),
        ],
      ),
    );
  }
}