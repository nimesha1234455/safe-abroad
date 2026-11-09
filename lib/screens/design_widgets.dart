import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';

Future<void> dial(String number) async {
  try {
    await launchUrl(Uri(scheme: 'tel', path: number));
  } catch (_) {}
}

String fmtNum(num n) {
  final s = n.round().abs().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return (n < 0 ? '-' : '') + b.toString();
}

/// Gradient header + hero + rounded white sheet (the look of the new design).
class GradientScreen extends StatelessWidget {
  final String title;
  final IconData? trailingIcon;
  final List<Color> colors;
  final Widget hero;
  final List<Widget> children;
  final Widget? footer;
  final Color sheetColor;

  const GradientScreen({
    super.key,
    required this.title,
    required this.colors,
    required this.hero,
    required this.children,
    this.trailingIcon,
    this.footer,
    this.sheetColor = kBg,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sheetColor,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: SingleChildScrollView(
          child: Column(children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: colors),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                    child: Row(children: [
                      IconButton(
                        tooltip: 'Back',
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.maybePop(context),
                      ),
                      Expanded(
                        child: Text(title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600)),
                      ),
                      SizedBox(
                        width: 48,
                        child: trailingIcon == null
                            ? null
                            : Icon(trailingIcon, color: Colors.white),
                      ),
                    ]),
                  ),
                  hero,
                ]),
              ),
            ),
            Stack(children: [
              Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 32,
                  child: ColoredBox(color: colors.last)),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: sheetColor,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: children),
              ),
            ]),
            if (footer != null) footer!,
          ]),
        ),
      ),
    );
  }
}

BoxDecoration whiteCard({double radius = 16}) => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: const Color(0xFFD6E0F5)),
      boxShadow: [
        BoxShadow(
            color: kNavy.withAlpha(18), blurRadius: 8, offset: const Offset(0, 3)),
      ],
    );