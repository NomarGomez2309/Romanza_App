import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../design_system/header_logo.dart';
import '../../design_system/romanza_icon.dart';
import '../../design_system/romanza_theme.dart';

/// Approved welcome composition. Decoration stays behind a scrollable, safe
/// content layer; controls grow with text rather than clipping or shrinking it.
class WelcomeLayout extends StatelessWidget {
  const WelcomeLayout({
    super.key,
    required this.onGoogle,
    required this.onEmail,
    required this.onLogin,
    required this.status,
  });
  final VoidCallback? onGoogle, onEmail, onLogin;
  final Widget status;

  @override
  Widget build(BuildContext context) {
    final c = RomanzaColors.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: ExcludeSemantics(
                child: CustomPaint(painter: WelcomeWaves(c)),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final height = constraints.maxHeight;
                return Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: (height * .15).clamp(48.0, 136.0)),
                          const _WelcomeBrand(),
                          const SizedBox(height: 36),
                          Semantics(
                            header: true,
                            child: Text(
                              'Más cotidiano.\nMás Romanza.',
                              style: RomanzaType.heading(
                                40,
                                44,
                                600,
                              ).copyWith(color: c.ink),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Un espacio para compartir sus días y guardar lo que importa, incluso a la distancia.',
                            style: RomanzaType.body.copyWith(
                              fontSize: 16,
                              height: 24 / 16,
                              color: c.secondary,
                            ),
                          ),
                          SizedBox(height: (height * .065).clamp(32.0, 60.0)),
                          _WelcomeButton(
                            key: const ValueKey('welcome-google'),
                            label: 'Continuar con Google',
                            onPressed: onGoogle,
                            background: Colors.white,
                            foreground: const Color(0xFF1F1F1F),
                            border: const Color(0xFFB6B8BD),
                            icon: SvgPicture.asset(
                              'assets/icons/providers/google-g.svg',
                              width: 24,
                              height: 24,
                              excludeFromSemantics: true,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _WelcomeButton(
                            key: const ValueKey('welcome-email'),
                            label: 'Continuar con correo',
                            onPressed: onEmail,
                            background: dark ? c.deep : c.note,
                            foreground: c.ink,
                            border: c.secondary.withValues(alpha: .4),
                            icon: RomanzaIcon(
                              RomanzaSymbol.mail,
                              size: 24,
                              color: c.ink,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: onLogin,
                            style: TextButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                            ),
                            child: const Text(
                              'Iniciar sesión',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          status,
                          SizedBox(height: (height * .18).clamp(64.0, 166.0)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeBrand extends StatelessWidget {
  const _WelcomeBrand();
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Romanza',
    image: true,
    child: ExcludeSemantics(
      child: Row(
        children: [
          if (Theme.of(
            context,
          ).extension<HeaderLogoTheme>()!.asset.endsWith('Romanza-Neo.svg'))
            SvgPicture.asset(
              'assets/logos/Welcome-Neo.svg',
              width: HeaderLogo.size.width,
              height: HeaderLogo.size.height,
              excludeFromSemantics: true,
            )
          else
            const HeaderLogo(),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              'Romanza',
              style: RomanzaType.heading(
                26,
                32,
                500,
              ).copyWith(color: RomanzaColors.of(context).ink),
            ),
          ),
        ],
      ),
    ),
  );
}

class _WelcomeButton extends StatelessWidget {
  const _WelcomeButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.background,
    required this.foreground,
    required this.border,
    required this.icon,
  });
  final String label;
  final VoidCallback? onPressed;
  final Color background, foreground, border;
  final Widget icon;
  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onPressed,
    style: OutlinedButton.styleFrom(
      backgroundColor: background,
      foregroundColor: foreground,
      disabledBackgroundColor: background.withValues(alpha: .65),
      disabledForegroundColor: foreground.withValues(alpha: .5),
      minimumSize: const Size.fromHeight(56),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      side: BorderSide(color: border),
      shape: const StadiumBorder(),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

/// Resolution-independent waves, normalized to the viewport. No raster UI,
/// animation or blur cost; the center remains clear for text and controls.
class WelcomeWaves extends CustomPainter {
  const WelcomeWaves(this.colors);
  final RomanzaColors colors;
  @override
  void paint(Canvas canvas, Size size) {
    final c = colors;
    final dark = c.background.computeLuminance() < .179;
    canvas.save();
    canvas.scale(size.width / 390, size.height / 844);
    void wave(Path path, Color color, double opacity) {
      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: opacity * .35),
              color.withValues(alpha: opacity),
            ],
          ).createShader(const Rect.fromLTWH(0, 0, 390, 844)),
      );
    }

    wave(
      Path()
        ..moveTo(0, 0)
        ..lineTo(390, 0)
        ..lineTo(390, 242)
        ..cubicTo(328, 176, 303, 187, 277, 123)
        ..cubicTo(228, 34, 85, 116, 0, 19)
        ..close(),
      c.deep,
      dark ? .75 : .45,
    );
    wave(
      Path()
        ..moveTo(44, 0)
        ..lineTo(390, 0)
        ..lineTo(390, 196)
        ..cubicTo(325, 139, 273, 151, 246, 78)
        ..cubicTo(209, 11, 122, 62, 44, 0)
        ..close(),
      c.primary,
      dark ? .17 : .34,
    );
    wave(
      Path()
        ..moveTo(211, 0)
        ..lineTo(390, 0)
        ..lineTo(390, 123)
        ..cubicTo(304, 116, 302, 29, 211, 0)
        ..close(),
      c.deep,
      dark ? .9 : .4,
    );
    wave(
      Path()
        ..moveTo(0, 742)
        ..cubicTo(70, 776, 53, 825, 160, 786)
        ..cubicTo(253, 739, 284, 797, 390, 807)
        ..lineTo(390, 844)
        ..lineTo(0, 844)
        ..close(),
      c.primary,
      dark ? .2 : .34,
    );
    wave(
      Path()
        ..moveTo(0, 778)
        ..cubicTo(78, 853, 111, 792, 193, 806)
        ..cubicTo(246, 816, 272, 838, 294, 844)
        ..lineTo(0, 844)
        ..close(),
      c.deep,
      dark ? .9 : .55,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant WelcomeWaves oldDelegate) =>
      oldDelegate.colors != colors;
}
