import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import 'home_screen.dart';
import 'login_screen.dart';

// Colors where the pictures meet the middle part
const _seamTop = Color(0xFF023FA1);
const _seamBottom = Color(0xFF0E71DE);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Start only after the first frame is drawn
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    // Load both pictures first, then wait 3 seconds
    await Future.wait([
      precacheImage(const AssetImage('assets/images/splash_top.jpg'), context),
      precacheImage(
          const AssetImage('assets/images/splash_bottom.jpg'), context),
    ]);
    await Future.delayed(const Duration(seconds: 3));

    // Logged in (or chose Guest before) -> Home. Otherwise -> Login.
    final skip = await AuthService.shouldSkipLogin();
    if (!mounted) return;
    final Widget next = skip ? const HomeScreen() : const LoginScreen();

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => next,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  // App name, subtitle and tagline
  Widget _titleBlock() {
    const shadow = [Shadow(color: Colors.black38, blurRadius: 8)];
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      builder: (context, v, child) => Opacity(opacity: v, child: child),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text.rich(
            TextSpan(children: [
              TextSpan(text: 'Safe ', style: TextStyle(color: Colors.white)),
              TextSpan(text: 'Abroad', style: TextStyle(color: kGold)),
            ]),
            style: TextStyle(
                fontSize: 46, fontWeight: FontWeight.bold, shadows: shadow),
          ),
          const SizedBox(height: 4),
          // "Agency Checker" with a line on each side
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(children: [
              const Expanded(child: Divider(color: Colors.white54)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('Agency Checker',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        shadows: shadow)),
              ),
              const Expanded(child: Divider(color: Colors.white54)),
            ]),
          ),
          const SizedBox(height: 10),
          const Text('Travel Safe... Build a Better Future...',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                  shadows: shadow)),
          const SizedBox(height: 6),
          Container(
            width: 200,
            height: 3,
            decoration: BoxDecoration(
                color: kGold, borderRadius: BorderRadius.circular(2)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _seamTop,
      body: Stack(
        children: [
          Column(
            children: [
              // Top picture: world map, plane, logo
              Stack(
                children: [
                  Image.asset('assets/images/splash_top.jpg',
                      width: double.infinity, fit: BoxFit.fitWidth),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 10,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x00023FA1), _seamTop],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Middle: title text
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [_seamTop, _seamBottom],
                    ),
                  ),
                  child: Center(child: _titleBlock()),
                ),
              ),
              // Bottom picture: traveler, city, wave
              Stack(
                children: [
                  Image.asset('assets/images/splash_bottom.jpg',
                      width: double.infinity, fit: BoxFit.fitWidth),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    height: 30,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [_seamBottom, Color(0x000E71DE)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Loading bar on the dark wave
          Positioned(
            left: 0,
            right: 0,
            bottom: 8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 120,
                  child: LinearProgressIndicator(
                    minHeight: 3,
                    color: kGold,
                    backgroundColor: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 6),
                const Text('Loading...',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}