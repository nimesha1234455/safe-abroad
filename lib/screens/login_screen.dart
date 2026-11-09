import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import 'home_screen.dart';
import 'otp_screen.dart';

// Add your own links here when you have them
const kPrivacyUrl = '';
const kTermsUrl = '';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phone = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  // +94771234567 or null when the number is not a Sri Lankan mobile
  String? _fullNumber() {
    var d = _phone.text.replaceAll(RegExp(r'\D'), '');
    if (d.startsWith('94')) d = d.substring(2);
    d = d.replaceFirst(RegExp(r'^0+'), '');
    if (!RegExp(r'^7\d{8}$').hasMatch(d)) return null;
    return '+94$d';
  }

  Future<void> _sendOtp() async {
    FocusScope.of(context).unfocus();
    final full = _fullNumber();
    if (full == null) {
      setState(() => _error = 'Enter a valid mobile number, for example 77 123 4567');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await AuthService.sendOtp(full);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => OtpScreen(phone: full)),
      );
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error =
            'Could not connect. Check your internet and try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _guest() async {
    await AuthService.continueAsGuest();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (r) => false,
    );
  }

  Future<void> _link(String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This link is not added yet')));
      return;
    }
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Widget _header() {
    const shadow = [Shadow(color: Colors.black45, blurRadius: 6)];
    return SizedBox(
      height: 300,
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
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(children: [
                        TextSpan(
                            text: 'Safe ',
                            style: TextStyle(color: Colors.white)),
                        TextSpan(
                            text: 'Abroad',
                            style: TextStyle(color: kGold)),
                      ]),
                      style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          shadows: shadow),
                    ),
                    Text('Your Journey, Our Priority',
                        style: TextStyle(
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                            fontSize: 16,
                            shadows: shadow)),
                  ],
                ),
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
      backgroundColor: kBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _header(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Text('Welcome Back!',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: kNavy)),
                  const SizedBox(height: 6),
                  const Text(
                    'Login to get access to your safety tools\nand travel support.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 20),
                  // Country code (fixed) + mobile number
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFC9D8F0)),
                    ),
                    child: Row(children: [
                      const Text('🇱🇰', style: TextStyle(fontSize: 26)),
                      const SizedBox(width: 8),
                      const Text('+94',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold)),
                      Container(
                          width: 1,
                          height: 30,
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          color: Colors.black12),
                      Expanded(
                        child: TextField(
                          controller: _phone,
                          keyboardType: TextInputType.phone,
                          maxLength: 12,
                          onSubmitted: (_) => _sendOtp(),
                          decoration: const InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                            hintText: 'Enter your mobile number',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                        ),
                      ),
                    ]),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(_error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: kRed)),
                    ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: kBlue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(27)),
                      ),
                      onPressed: _busy ? null : _sendOtp,
                      icon: _busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.send),
                      label: const Text('Send OTP',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Row(children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('or'),
                    ),
                    Expanded(child: Divider()),
                  ]),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(220, 46),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(23)),
                      side: const BorderSide(color: kNavy, width: 1.5),
                    ),
                    onPressed: _guest,
                    icon: const Icon(Icons.person, color: kNavy),
                    label: const Text('Continue as Guest',
                        style: TextStyle(
                            color: kNavy, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            // Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: const BoxDecoration(
                color: kNavy,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified_user, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Your data is safe with us',
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => _link(kPrivacyUrl),
                      child: const Text('Privacy Policy',
                          style: TextStyle(color: Colors.white)),
                    ),
                    const Text('|', style: TextStyle(color: Colors.white)),
                    TextButton(
                      onPressed: () => _link(kTermsUrl),
                      child: const Text('Terms of Service',
                          style: TextStyle(
                              color: Colors.white,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white)),
                    ),
                  ],
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}