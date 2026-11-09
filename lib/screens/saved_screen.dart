import 'package:flutter/material.dart';
import '../models/agency.dart';
import '../services/saved_service.dart';
import '../theme.dart';
import 'checker_screen.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  List<Agency> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await SavedService.load();
    if (!mounted) return;
    setState(() {
      _items = list;
      _loading = false;
    });
  }

  Color _color(Agency a) {
    if (a.status == 'cancelled') return kRed;
    if (a.status == 'suspended') return kOrange;
    return a.isExpired ? kOrange : kGreen;
  }

  String _label(Agency a) {
    if (a.status == 'cancelled') return 'Cancelled';
    if (a.status == 'suspended') return 'Suspended';
    return a.isExpired ? 'License expired' : 'Registered';
  }

  IconData _icon(Agency a) {
    if (a.status == 'cancelled') return Icons.cancel;
    if (a.status == 'suspended' || a.isExpired) return Icons.warning_rounded;
    return Icons.check_circle;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Agencies')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No saved agencies yet.\nTap the bookmark icon on a search result to save it.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text(
                        'Saved details can be out of date. Tap an agency to check its current status.',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ),
                    for (final a in _items)
                      Card(
                        color: Colors.white,
                        surfaceTintColor: Colors.transparent,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _color(a),
                            child: Icon(_icon(a), color: Colors.white),
                          ),
                          title: Text(a.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, color: kNavy)),
                          subtitle:
                              Text('License ${a.licenseNo} • ${_label(a)}'),
                          trailing: IconButton(
                            tooltip: 'Remove',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              await SavedService.toggle(a);
                              _load();
                            },
                          ),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CheckerScreen(initialQuery: a.licenseNo),
                              ),
                            );
                            _load();
                          },
                        ),
                      ),
                  ],
                ),
    );
  }
}