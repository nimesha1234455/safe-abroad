// Country guide screen: search, region filter and a 2 column country grid

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';

// Default official site (SLBFE)
const String _slbfe = 'https://www.slbfe.lk';

// Simple model to hold data for one country
class CountryInfo {
  final String name;
  final String alias; // other name used in search, example: UAE
  final String flag;
  final String region; // Middle East, Asia or Europe
  final List<String> points; // short info lines (empty = not added yet)
  final String linkLabel; // text on the link button inside the popup
  final String linkUrl; // official site
  final String note; // small reminder

  const CountryInfo({
    required this.name,
    this.alias = '',
    required this.flag,
    required this.region,
    this.points = const [],
    this.linkLabel = 'SLBFE Official Website',
    this.linkUrl = _slbfe,
    this.note = '',
  });
}

// All country data lives here. To add a country, add one more CountryInfo.
// Countries with an empty "points" list show a "not added yet" message,
// so no wrong information is ever shown.
const List<CountryInfo> countries = [
  CountryInfo(
    name: 'United Arab Emirates',
    alias: 'UAE',
    flag: '🇦🇪',
    region: 'Middle East',
    points: [
      'In June 2025 the minister said there is no legal minimum wage for migrant workers.',
      'Always check the salary written in your contract.',
    ],
    note: 'Info is from June 2025 and may have changed. Please confirm.',
  ),
  CountryInfo(
    name: 'Saudi Arabia',
    flag: '🇸🇦',
    region: 'Middle East',
    points: [
      'In June 2025 the minister said there is no legal minimum wage for migrant workers.',
      'Always check the salary written in your contract.',
    ],
    note: 'Info is from June 2025 and may have changed. Please confirm.',
  ),
  CountryInfo(
    name: 'Kuwait',
    flag: '🇰🇼',
    region: 'Middle East',
    points: [
      'Sri Lanka removed its own minimum wage rule for migrant workers on 13 Sept 2021.',
      'In June 2025 the minister said Kuwait minimum wage is about USD 240.',
    ],
    note: 'Info is from June 2025 and may have changed. Please confirm.',
  ),
  CountryInfo(
    name: 'Qatar',
    flag: '🇶🇦',
    region: 'Middle East',
    points: [
      'Qatar has a legal minimum wage for all workers: QAR 1,000 basic pay per month.',
      'If your employer does not give food, you must get at least QAR 300 more. '
          'If no housing, at least QAR 500 more.',
      'So the minimum is QAR 1,000 (food and housing given), QAR 1,300 '
          '(housing given, no food) or QAR 1,800 (neither given).',
    ],
    linkLabel: 'ILO Official Website',
    linkUrl: 'https://www.ilo.org',
    note: 'Check your contract. Pay below these amounts is not allowed.',
  ),
  CountryInfo(name: 'Oman', flag: '🇴🇲', region: 'Middle East'),
  CountryInfo(name: 'Bahrain', flag: '🇧🇭', region: 'Middle East'),
  CountryInfo(name: 'Jordan', flag: '🇯🇴', region: 'Middle East'),
  CountryInfo(name: 'Israel', flag: '🇮🇱', region: 'Middle East'),
  CountryInfo(
    name: 'Japan',
    flag: '🇯🇵',
    region: 'Asia',
    points: [
      'Two programs: SSW and TITP (agreement signed in 2017).',
      'Skills tests are held by the Japan government.',
      'Recruitment is only through SLBFE.',
    ],
    note: 'Check the maximum fee for each job in the SLBFE job bank.',
  ),
  CountryInfo(
    name: 'South Korea',
    flag: '🇰🇷',
    region: 'Asia',
    points: [
      'Only SLBFE has the legal right to send workers to Korea.',
      'Applicants must be 18 to 39 years old.',
      'Jobs are in 4 sectors: fishery, manufacturing, construction and shipbuilding.',
      'You must pass the EPS-TOPIK Korean language exam first.',
    ],
    linkLabel: 'SLBFE Korea Page',
    linkUrl: 'https://www.slbfe.lk/slbfe-recruitment-co/recruitment-korea/',
    note: 'Never pay a private person for a Korea job. Call 1989 to check.',
  ),
  CountryInfo(name: 'Malaysia', flag: '🇲🇾', region: 'Asia'),
  CountryInfo(name: 'Singapore', flag: '🇸🇬', region: 'Asia'),
  CountryInfo(name: 'Maldives', flag: '🇲🇻', region: 'Asia'),
  CountryInfo(name: 'Romania', flag: '🇷🇴', region: 'Europe'),
  CountryInfo(name: 'Cyprus', flag: '🇨🇾', region: 'Europe'),
];

class CountryGuideScreen extends StatefulWidget {
  const CountryGuideScreen({super.key});

  @override
  State<CountryGuideScreen> createState() => _CountryGuideScreenState();
}

class _CountryGuideScreenState extends State<CountryGuideScreen> {
  static const Color _pageBg = Color(0xFFEFF4FF);
  static const List<String> _filters = ['All', 'Middle East', 'Asia', 'Europe'];
  static const List<IconData> _filterIcons = [
    Icons.public,
    Icons.mosque,
    Icons.language,
    Icons.account_balance,
  ];

  final _search = TextEditingController();
  String _query = '';
  String _filter = 'All';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  // Countries that match the search and the filter
  List<CountryInfo> get _visible {
    final q = _query.trim().toLowerCase();
    return countries.where((c) {
      final okRegion = _filter == 'All' || c.region == _filter;
      final okName = q.isEmpty ||
          c.name.toLowerCase().contains(q) ||
          c.alias.toLowerCase().contains(q);
      return okRegion && okName;
    }).toList();
  }

  // Open a link in the phone browser
  Future<void> _openLink(String url) async {
    var ok = false;
    try {
      ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      ok = false;
    }
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the link')),
      );
    }
  }

  // Popup with all the details of one country
  void _showDetails(CountryInfo c) {
    final hasInfo = c.points.isNotEmpty;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.8,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(c.flag, style: const TextStyle(fontSize: 38)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.name,
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              color: kNavy,
                            ),
                          ),
                          Text(
                            c.region,
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (hasInfo) ...[
                  for (final p in c.points)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('• $p', style: const TextStyle(fontSize: 15)),
                    ),
                  if (c.note.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      c.note,
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ] else
                  // No verified information yet: say so, and show safe steps
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFFB74D)),
                    ),
                    child: const Text(
                      'Information for this country has not been added yet.\n\n'
                      '• Call SLBFE hotline 1989 for the rules and the minimum '
                      'salary.\n'
                      '• Check your agency licence in the Agency Checker before '
                      'you pay.\n'
                      '• Read your contract before you sign.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: kNavy),
                    onPressed: () => _openLink(c.linkUrl),
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: Text(c.linkLabel),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
              InkWell(
                customBorder: const CircleBorder(),
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlpha(40),
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Country Guide',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Explore destinations & official information',
                      style: TextStyle(fontSize: 13, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Transform.rotate(
                angle: -0.4,
                child: const Icon(Icons.flight, color: Colors.white70, size: 40),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.public, color: Colors.white, size: 44),
            ],
          ),
        ),
      ),
    );
  }

  // Search box
  Widget _searchBox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: kNavy.withAlpha(25),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _search,
        onChanged: (v) => setState(() => _query = v),
        textInputAction: TextInputAction.search,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Search countries...',
          prefixIcon: const Icon(Icons.search, color: kNavy, size: 28),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _search.clear();
                    setState(() => _query = '');
                  },
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  // Row of filter buttons: All, Middle East, Asia, Europe
  Widget _filterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < _filters.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => setState(() => _filter = _filters[i]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                  decoration: BoxDecoration(
                    color: _filter == _filters[i] ? kNavy : Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: kBlue.withAlpha(70)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _filterIcons[i],
                        size: 20,
                        color: _filter == _filters[i] ? Colors.white : kNavy,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _filters[i],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _filter == _filters[i] ? Colors.white : kNavy,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Small button that shrinks its text to fit
  Widget _fitLabel(String text) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        maxLines: 1,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }

  // One country card
  Widget _countryCard(CountryInfo c) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kNavy.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => _showDetails(c),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.flag, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: kNavy,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 13, color: Colors.black45),
                          const SizedBox(width: 2),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                c.region,
                                maxLines: 1,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black54),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: kNavy, size: 22),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 5,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: kNavy,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    minimumSize: const Size(0, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () => _showDetails(c),
                  icon: const Icon(Icons.visibility, size: 14),
                  label: _fitLabel('Details'),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                flex: 6,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kNavy,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    minimumSize: const Size(0, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    side: BorderSide(color: kBlue.withAlpha(120)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () => _openLink(c.linkUrl),
                  icon: const Icon(Icons.verified_user, size: 14),
                  label: _fitLabel('Official Source'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Cards in two columns
  Widget _grid(List<CountryInfo> list) {
    final rows = <Widget>[];
    for (int i = 0; i < list.length; i += 2) {
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _countryCard(list[i])),
                const SizedBox(width: 12),
                Expanded(
                  child: i + 1 < list.length
                      ? _countryCard(list[i + 1])
                      : const SizedBox(),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Column(children: rows);
  }

  // Message when nothing matches the search
  Widget _noResult() {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off, size: 40, color: kBlue),
          SizedBox(height: 8),
          Text(
            'No country found.\nTry another name or call hotline 1989.',
            textAlign: TextAlign.center,
            style: TextStyle(color: kNavy, fontSize: 15),
          ),
        ],
      ),
    );
  }

  // Note at the bottom
  Widget _bottomNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFDCE8FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBlue.withAlpha(40)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: kNavy,
            ),
            child: const Icon(Icons.info_outline, color: Colors.white),
          ),
          Container(
            width: 1,
            height: 48,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: kNavy.withAlpha(60),
          ),
          const Expanded(
            child: Text(
              'Job availability and entry rules change. Check current SLBFE '
              'and official government information before applying.',
              style: TextStyle(color: kNavy, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _visible;
    return Scaffold(
      backgroundColor: _pageBg,
      body: Column(
        children: [
          _header(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                _searchBox(),
                const SizedBox(height: 14),
                _filterChips(),
                const SizedBox(height: 14),
                if (list.isEmpty) _noResult() else _grid(list),
                const SizedBox(height: 4),
                _bottomNote(),
                const SizedBox(height: 10),
                const Text(
                  'Personal app, not a government app. '
                  'Please confirm all details with slbfe.lk or hotline 1989.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}