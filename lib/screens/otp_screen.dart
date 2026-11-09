import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import 'home_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phone; // +94771234567
  const OtpScreen({super.key, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _code = TextEditingController();
  final _focus = FocusNode();
  Timer? _timer;
  int _left = 180; // code lives 3 minutes
  int _cooldown = 60; // wait before asking for a new code
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _left = 180;
    _cooldown = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_left > 0) _left--;
        if (_cooldown > 0) _cooldown--;
      });
    });
  }

  String get _mmss =>
      '${(_left ~/ 60).toString().padLeft(2, '0')}:${(_left % 60).toString().padLeft(2, '0')}';

  // +94771234567 -> +94 77 123 4567
  String get _pretty {
    final p = widget.phone;
    if (p.length != 12) return p;
    return '+94 ${p.substring(3, 5)} ${p.substring(5, 8)} ${p.substring(8)}';
  }

  Future<void> _verify() async {
    if (_busy) return;
    final code = _code.text.trim();
    if (code.length != 6) {
      setState(() => _error = 'Enter the 6-digit code');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await AuthService.verifyOtp(widget.phone, code);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (r) => false,
      );
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _code.clear();
        });
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not connect. Try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    if (_cooldown > 0 || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await AuthService.sendOtp(widget.phone);
      if (!mounted) return;
      _code.clear();
      _startTimer();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('A new code was sent')));
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not connect. Try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _boxes() {
    final text = _code.text;
    return GestureDetector(
      onTap: () => _focus.requestFocus(),
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < 6; i++)
                Container(
                  width: 46,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: i == text.length ? kBlue : const Color(0xFFC9D8F0),
                      width: i == text.length ? 2 : 1,
                    ),
                  ),
                  child: Text(i < text.length ? text[i] : '',
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: kNavy)),
                ),
            ],
          ),
          // Invisible field that receives the typing
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: _code,
                focusNode: _focus,
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(counterText: ''),
                onChanged: (v) {
                  setState(() => _error = null);
                  if (v.length == 6) _verify();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expired = _left == 0;
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: kNavy,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const Text.rich(
              TextSpan(children: [
                TextSpan(text: 'Safe ', style: TextStyle(color: kNavy)),
                TextSpan(text: 'Abroad', style: TextStyle(color: kBlue)),
              ]),
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('OTP Verification',
                style: TextStyle(
                    fontSize: 26, fontWeight: FontWeight.bold, color: kNavy)),
            const SizedBox(height: 8),
            const Text('We have sent a 6-digit OTP to'),
            const SizedBox(height: 8),
            ActionChip(
              label: Text(_pretty,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: kNavy)),
              avatar: const Icon(Icons.edit, size: 16, color: kNavy),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 20),
            _boxes(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.access_time, size: 18),
                const SizedBox(width: 6),
                Text(expired ? 'The code has expired' : 'OTP will expire in '),
                if (!expired)
                  Text(_mmss,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: kBlue)),
              ],
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(_error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: kRed)),
              ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: kBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27)),
                ),
                onPressed: (_busy || expired) ? null : _verify,
                icon: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check),
                label: const Text('Verify & Login',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _cooldown > 0 || _busy ? null : _resend,
              icon: const Icon(Icons.refresh),
              label: Text(
                  _cooldown > 0 ? 'Resend OTP in ${_cooldown}s' : 'Resend OTP',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}