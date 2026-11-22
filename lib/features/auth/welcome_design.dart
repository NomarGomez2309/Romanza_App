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
                child: RepaintBoundary(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Opacity(
                        opacity: .15,
                        child: CustomPaint(painter: WelcomeWaves(c)),
                      ),
                      CustomPaint(painter: WelcomeConnection(c)),
                    ],
                  ),
                ),
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
                              fontSize: 18,
                              height: 26 / 18,
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
                              colorFilter: const ColorFilter.mode(
                                Color(0xFF1F1F1F),
                                BlendMode.srcIn,
                              ),
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
                650,
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

/// Layered vector ribbons with soft contact shadows and a narrow lit edge.
/// RepaintBoundary isolates the static relief from session status updates.
class WelcomeWaves extends CustomPainter {
  const WelcomeWaves(this.colors);
  final RomanzaColors colors;
  @override
  void paint(Canvas canvas, Size size) {
    final c = colors;
    final dark = c.background.computeLuminance() < .179;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.scale(size.width / 390, size.height / 844);
    void wave(Path path, Color color, double strength) {
      final base = Color.lerp(c.background, color, strength)!;
      // Contact shadow falls onto the lower ribbon, beyond the cut edge.
      canvas.save();
      canvas.translate(0, 4);
      canvas.drawPath(
        path,
        Paint()
          ..color = (dark ? c.primary : c.secondary).withValues(
            alpha: dark ? .24 : .18,
          )
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
      );
      canvas.restore();
      final bounds = path.getBounds();
      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(base, dark ? Colors.black : Colors.white, .42)!,
              base,
              Color.lerp(base, color, .24)!,
            ],
            stops: const [0, .65, 1],
          ).createShader(bounds),
      );
      // Both strokes are clipped to the upper ribbon: a rounded inner bevel,
      // then a very fine highlight, rather than a hard outline or neon glow.
      canvas.save();
      canvas.clipPath(path);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12
          ..color = (dark ? c.primary : Colors.white).withValues(
            alpha: dark ? .16 : .7,
          )
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = .8
          ..color = (dark ? c.primary : Colors.white).withValues(
            alpha: dark ? .25 : .72,
          ),
      );
      canvas.restore();
    }

    // Shallow ribbons leave the connection motif and all content unobstructed.
    wave(
      Path()
        ..moveTo(0, 0)
        ..lineTo(390, 0)
        ..lineTo(390, 34)
        ..cubicTo(298, 69, 260, 8, 190, 24)
        ..cubicTo(102, 46, 67, 47, 0, 17)
        ..close(),
      c.deep,
      dark ? .9 : .78,
    );
    wave(
      Path()
        ..moveTo(0, 0)
        ..lineTo(390, 0)
        ..lineTo(390, 24)
        ..cubicTo(298, 57, 259, 0, 188, 15)
        ..cubicTo(106, 34, 64, 37, 0, 8)
        ..close(),
      c.primary,
      dark ? .5 : .72,
    );
    wave(
      Path()
        ..moveTo(0, 0)
        ..lineTo(390, 0)
        ..lineTo(390, 9)
        ..cubicTo(300, 34, 259, -8, 190, 1)
        ..cubicTo(100, 22, 58, 24, 0, 0)
        ..close(),
      c.deep,
      dark ? .9 : .45,
    );
    wave(
      Path()
        ..moveTo(0, 766)
        ..cubicTo(76, 790, 62, 820, 151, 795)
        ..cubicTo(246, 761, 288, 808, 390, 820)
        ..lineTo(390, 844)
        ..lineTo(0, 844)
        ..close(),
      c.primary,
      dark ? .5 : .72,
    );
    wave(
      Path()
        ..moveTo(0, 784)
        ..cubicTo(76, 813, 65, 834, 154, 809)
        ..cubicTo(245, 782, 290, 824, 390, 834)
        ..lineTo(390, 844)
        ..lineTo(0, 844)
        ..close(),
      c.deep,
      dark ? .9 : .78,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant WelcomeWaves oldDelegate) =>
      oldDelegate.colors != colors;
}

/// Two individual paths meet gently above the brand. Their own contrast is
/// independent of the 15% wave opacity. Static, decorative and theme-aware.
class WelcomeConnection extends CustomPainter {
  const WelcomeConnection(this.colors);
  final RomanzaColors colors;
  @override
  void paint(Canvas canvas, Size size) {
    final dark = colors.background.computeLuminance() < .179;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.scale(size.width / 390, size.height / 844);
    final first = Path()
      ..moveTo(78, 54)
      ..cubicTo(143, 65, 193, 109, 254, 99)
      ..cubicTo(284, 86, 308, 101, 329, 108)
      ..cubicTo(352, 115, 372, 120, 390, 120);
    final second = Path()
      ..moveTo(185, 128)
      ..cubicTo(235, 119, 251, 91, 282, 99)
      ..cubicTo(323, 112, 333, 48, 390, 56);
    void thread(Path path, Color color) {
      final shader = LinearGradient(
        colors: [
          color.withValues(alpha: 0),
          color.withValues(alpha: dark ? .72 : .65),
          color.withValues(alpha: .8),
          color.withValues(alpha: .2),
        ],
        stops: const [0, .38, .76, 1],
      ).createShader(path.getBounds());
      canvas.save();
      canvas.translate(0, 1.2);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..color = color.withValues(alpha: .12)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
      );
      canvas.restore();
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.15
          ..strokeCap = StrokeCap.round
          ..shader = shader,
      );
    }

    thread(first, dark ? colors.ink : colors.primary);
    thread(second, colors.accent);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant WelcomeConnection oldDelegate) =>
      oldDelegate.colors != colors;
}
