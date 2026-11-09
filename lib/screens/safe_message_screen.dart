import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';

// Safe Message: ready-made emergency sentences.
// Works OFFLINE. The user can read it aloud, show it big, copy it or save it.
//
// IMPORTANT: the translations below were written without a native speaker.
// Please have a native speaker check each language before you publish the app.

class _Lang {
  final String code, name, native, tts;
  const _Lang(this.code, this.name, this.native, this.tts);
}

const _langs = <_Lang>[
  _Lang('ar', 'Arabic', 'العربية', 'ar-SA'),
  _Lang('en', 'English', 'English', 'en-US'),
  _Lang('ko', 'Korean', '한국어', 'ko-KR'),
  _Lang('ja', 'Japanese', '日本語', 'ja-JP'),
  _Lang('ms', 'Malay', 'Bahasa Melayu', 'ms-MY'),
];

// Groups of sentences
const _cats = <String>[
  'Medical help',
  'Salary & contract',
  'Embassy & police',
  'Safety',
];
const _catIcons = <IconData>[
  Icons.medical_services,
  Icons.payments,
  Icons.account_balance,
  Icons.shield,
];
const _catColors = <Color>[kRed, kGreen, Colors.teal, kBlue];

class _Msg {
  final String id;
  final int cat; // index in _cats
  final String si; // Sinhala (what the user reads)
  final Map<String, String> t; // translations by language code
  const _Msg(this.id, this.cat, this.si, this.t);
}

const _messages = <_Msg>[
  // ---- Medical help ----
  _Msg('m1', 0, 'මට වෛද්‍ය උපකාර අවශ්‍යයි.', {
    'ar': 'أحتاج إلى مساعدة طبية.',
    'en': 'I need medical help.',
    'ko': '의료 도움이 필요합니다.',
    'ja': '医療的な助けが必要です。',
    'ms': 'Saya memerlukan bantuan perubatan.',
  }),
  _Msg('m2', 0, 'මට හදිසි උදව්වක් අවශ්‍යයි.', {
    'ar': 'أحتاج إلى مساعدة عاجلة.',
    'en': 'I need urgent help.',
    'ko': '긴급한 도움이 필요합니다.',
    'ja': '緊急の助けが必要です。',
    'ms': 'Saya memerlukan bantuan segera.',
  }),
  _Msg('m3', 0, 'කරුණාකර ගිලන් රථයක් (ambulance) කැඳවන්න.', {
    'ar': 'من فضلك اتصل بالإسعاف.',
    'en': 'Please call an ambulance.',
    'ko': '구급차를 불러 주세요.',
    'ja': '救急車を呼んでください。',
    'ms': 'Sila panggil ambulans.',
  }),
  // ---- Salary & contract ----
  _Msg('s1', 1, 'මගේ වැටුප ලැබී නැහැ.', {
    'ar': 'لم أستلم راتبي.',
    'en': 'I have not received my salary.',
    'ko': '월급을 받지 못했습니다.',
    'ja': '給料をもらっていません。',
    'ms': 'Saya belum menerima gaji saya.',
  }),
  _Msg('s2', 1, 'කරුණාකර මගේ ගිවිසුමේ සඳහන් වැටුප ගෙවන්න.', {
    'ar': 'من فضلك ادفع لي الراتب المذكور في عقدي.',
    'en': 'Please pay the salary written in my contract.',
    'ko': '계약서에 명시된 급여를 지급해 주세요.',
    'ja': '契約書に書かれている給料を支払ってください。',
    'ms': 'Sila bayar gaji yang dinyatakan dalam kontrak saya.',
  }),
  _Msg('s3', 1, 'කරුණාකර මගේ ගමන් බලපත්‍රය (passport) මට දෙන්න.', {
    'ar': 'من فضلك أعد لي جواز سفري.',
    'en': 'Please give me back my passport.',
    'ko': '제 여권을 돌려주세요.',
    'ja': 'パスポートを返してください。',
    'ms': 'Sila pulangkan pasport saya.',
  }),
  // ---- Embassy & police ----
  _Msg('e1', 2, 'මට ශ්‍රී ලංකා තානාපති කාර්යාලය සම්බන්ධ කරගැනීමට අවශ්‍යයි.', {
    'ar': 'أحتاج إلى الاتصال بسفارة سريلانكا.',
    'en': 'I need to contact the Sri Lanka embassy.',
    'ko': '스리랑카 대사관에 연락해야 합니다.',
    'ja': 'スリランカ大使館に連絡したいです。',
    'ms': 'Saya perlu menghubungi Kedutaan Sri Lanka.',
  }),
  _Msg('e2', 2, 'කරුණාකර පොලීසියට කතා කරන්න.', {
    'ar': 'من فضلك اتصل بالشرطة.',
    'en': 'Please call the police.',
    'ko': '경찰을 불러 주세요.',
    'ja': '警察を呼んでください。',
    'ms': 'Sila panggil polis.',
  }),
  _Msg('e3', 2, 'මට පරිවර්තකයෙක් අවශ්‍යයි.', {
    'ar': 'أحتاج إلى مترجم.',
    'en': 'I need an interpreter.',
    'ko': '통역사가 필요합니다.',
    'ja': '通訳が必要です。',
    'ms': 'Saya memerlukan jurubahasa.',
  }),
  // ---- Safety ----
  _Msg('f1', 3, 'මට ආරක්ෂාවක් දැනෙන්නේ නැහැ.', {
    'ar': 'لا أشعر بالأمان.',
    'en': 'I do not feel safe.',
    'ko': '안전하다고 느끼지 않습니다.',
    'ja': '身の危険を感じます。',
    'ms': 'Saya rasa tidak selamat.',
  }),
  _Msg('f2', 3, 'මට බලෙන් වැඩ කරවනවා.', {
    'ar': 'يتم إجباري على العمل رغماً عني.',
    'en': 'I am being forced to work against my will.',
    'ko': '저는 강제로 일하고 있습니다.',
    'ja': '私は無理やり働かされています。',
    'ms': 'Saya dipaksa bekerja.',
  }),
  _Msg('f3', 3, 'මට තේරෙන්නේ නැහැ. කරුණාකර හෙමින් කතා කරන්න.', {
    'ar': 'لا أفهم. من فضلك تحدث ببطء.',
    'en': 'I do not understand. Please speak slowly.',
    'ko': '이해하지 못했습니다. 천천히 말씀해 주세요.',
    'ja': 'わかりません。ゆっくり話してください。',
    'ms': 'Saya tidak faham. Sila cakap perlahan-lahan.',
  }),
];

class SafeMessageScreen extends StatefulWidget {
  const SafeMessageScreen({super.key});

  @override
  State<SafeMessageScreen> createState() => _SafeMessageScreenState();
}

class _SafeMessageScreenState extends State<SafeMessageScreen> {
  static const _pageBg = Color(0xFFEFF4FF);
  static const _savedKey = 'safe_msg_saved';

  final FlutterTts _tts = FlutterTts();
  _Lang _lang = _langs.first;
  bool _onlySaved = false;
  Set<String> _saved = {};

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _loadSaved() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _saved = (p.getStringList(_savedKey) ?? []).toSet());
  }

  Future<void> _toggleSaved(String id) async {
    setState(() {
      if (!_saved.remove(id)) _saved.add(id);
    });
    final p = await SharedPreferences.getInstance();
    await p.setStringList(_savedKey, _saved.toList());
  }

  void _msg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  // Read the sentence aloud in the chosen language
  Future<void> _speak(String text) async {
    try {
      final ok = await _tts.isLanguageAvailable(_lang.tts);
      if (ok != true && ok != 1) {
        _msg('This phone has no ${_lang.name} voice. Install it in the phone '
            'settings: Text-to-speech.');
        return;
      }
      await _tts.setLanguage(_lang.tts);
      await _tts.setSpeechRate(0.45);
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {
      _msg('Could not play the voice on this phone.');
    }
  }

  Future<void> _copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    _msg('Copied');
  }

  // Full screen with big letters, to show to another person
  void _show(String text) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ShowPage(
          text: text,
          rtl: _lang.code == 'ar',
          onSpeak: () => _speak(text),
        ),
      ),
    );
  }

  Future<void> _callHotline() async {
    try {
      await launchUrl(Uri(scheme: 'tel', path: '1989'));
    } catch (_) {
      _msg('Could not open the phone app.');
    }
  }

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

  Widget _header() {
    return ClipPath(
      clipper: _WaveClipper(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          16,
          MediaQuery.of(context).padding.top + 8,
          16,
          40,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Safe Message',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Say it in their language. Works offline.',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.record_voice_over, color: Colors.white, size: 38),
          ],
        ),
      ),
    );
  }

  // Language buttons and the "Saved" filter
  Widget _chips() {
    Widget chip({
      required bool selected,
      required VoidCallback onTap,
      required Widget child,
    }) {
      return Padding(
        padding: const EdgeInsets.only(right: 10),
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? kNavy : Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: kBlue.withAlpha(70)),
            ),
            child: child,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final l in _langs)
            chip(
              selected: _lang.code == l.code,
              onTap: () => setState(() => _lang = l),
              child: Text(
                '${l.name}  ${l.native}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _lang.code == l.code ? Colors.white : kNavy,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _savedToggle() {
    return Row(
      children: [
        const Text(
          'Translate into',
          style: TextStyle(color: kNavy, fontWeight: FontWeight.w800, fontSize: 16),
        ),
        const Spacer(),
        FilterChip(
          avatar: Icon(
            _onlySaved ? Icons.star : Icons.star_border,
            size: 18,
            color: _onlySaved ? Colors.white : kNavy,
          ),
          label: const Text('Saved'),
          selected: _onlySaved,
          selectedColor: kNavy,
          checkmarkColor: Colors.white,
          showCheckmark: false,
          labelStyle: TextStyle(
            color: _onlySaved ? Colors.white : kNavy,
            fontWeight: FontWeight.w700,
          ),
          onSelected: (v) => setState(() => _onlySaved = v),
        ),
      ],
    );
  }

  Widget _action(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: TextButton.icon(
        style: TextButton.styleFrom(
          foregroundColor: kBlue,
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(label, style: const TextStyle(fontSize: 13)),
      ),
    );
  }

  Widget _messageCard(_Msg m) {
    final text = m.t[_lang.code] ?? '';
    final saved = _saved.contains(m.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 6),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  m.si,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14.5,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  saved ? Icons.star : Icons.star_border,
                  color: saved ? const Color(0xFFFFB300) : Colors.black38,
                ),
                onPressed: () => _toggleSaved(m.id),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                text,
                textDirection:
                    _lang.code == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                textAlign:
                    _lang.code == 'ar' ? TextAlign.right : TextAlign.left,
                style: const TextStyle(
                  color: kNavy,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _action(Icons.volume_up, 'Speak', () => _speak(text)),
              _action(Icons.fullscreen, 'Show', () => _show(text)),
              _action(Icons.copy, 'Copy', () => _copy(text)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _groupTitle(int ci) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _catColors[ci].withAlpha(30),
            ),
            child: Icon(_catIcons[ci], color: _catColors[ci], size: 20),
          ),
          const SizedBox(width: 10),
          Text(
            _cats[ci],
            style: const TextStyle(
              color: kNavy,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var ci = 0; ci < _cats.length; ci++) {
      final list = _messages
          .where((m) => m.cat == ci && (!_onlySaved || _saved.contains(m.id)))
          .toList();
      if (list.isEmpty) continue;
      children.add(_groupTitle(ci));
      for (final m in list) {
        children.add(_messageCard(m));
      }
    }
    if (children.isEmpty) {
      children.add(
        Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(20),
          decoration: _card(),
          child: const Text(
            'No saved sentences yet. Tap the star on a sentence to save it here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: kNavy),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _pageBg,
      body: Column(
        children: [
          _header(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                _savedToggle(),
                const SizedBox(height: 10),
                _chips(),
                const SizedBox(height: 8),
                ...children,
                const SizedBox(height: 8),
                // Note and hotline button
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCE8FF),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: kBlue.withAlpha(40)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'These are ready-made sentences. In an emergency, also '
                        'call the SLBFE hotline 1989 or your embassy. To hear '
                        'the voice, the phone needs a text-to-speech voice for '
                        'that language.',
                        style: TextStyle(color: kNavy, fontSize: 12.5),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(backgroundColor: kRed),
                          onPressed: _callHotline,
                          icon: const Icon(Icons.call),
                          label: const Text('Call hotline 1989'),
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
    );
  }
}

// Big letters on a full screen (to show to a doctor, an employer or the police)
class _ShowPage extends StatelessWidget {
  final String text;
  final bool rtl;
  final VoidCallback onSpeak;
  const _ShowPage({required this.text, required this.rtl, required this.onSpeak});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: kNavy,
        foregroundColor: Colors.white,
        title: const Text('Show this message'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: kBlue,
                    minimumSize: const Size.fromHeight(54),
                  ),
                  onPressed: onSpeak,
                  icon: const Icon(Icons.volume_up),
                  label: const Text('Speak', style: TextStyle(fontSize: 18)),
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