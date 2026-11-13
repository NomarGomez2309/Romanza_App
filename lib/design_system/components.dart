import 'package:romanza/design_system/romanza_icon.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'romanza_theme.dart';

class RomanzaPage extends StatelessWidget {
  const RomanzaPage({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: RomanzaSpace.maxWidth),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: child,
      ),
    ),
  );
}

class RomanzaEmptyState extends StatelessWidget {
  const RomanzaEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });
  final RomanzaSymbol icon;
  final String title, message;
  final Widget? action;
  @override
  Widget build(BuildContext context) {
    final c = RomanzaColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: c.note,
                borderRadius: BorderRadius.circular(28),
              ),
              child: RomanzaIcon(icon, size: 36),
            ),
          ),
          const SizedBox(height: 24),
          Text(title, style: RomanzaType.section, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            message,
            style: RomanzaType.body.copyWith(color: c.secondary),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[const SizedBox(height: 24), action!],
        ],
      ),
    );
  }
}

Future<void> showRomanzaInfo(
  BuildContext context, {
  required String title,
  required String message,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: RomanzaType.section),
            const SizedBox(height: 12),
            Text(message, style: RomanzaType.body),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Entendido'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

enum BadgeShape { clover, hexagon }

class RomanzaBadge extends StatelessWidget {
  const RomanzaBadge({super.key, required this.icon, required this.shape});
  final RomanzaSymbol icon;
  final BadgeShape shape;
  @override
  Widget build(BuildContext context) {
    final c = RomanzaColors.of(context);
    return ExcludeSemantics(
      child: SizedBox(
        width: 44,
        height: 44,
        child: CustomPaint(
          painter: _BadgePainter(c.background, shape),
          child: RomanzaIcon(icon, size: 26, color: c.ink),
        ),
      ),
    );
  }
}

class _BadgePainter extends CustomPainter {
  const _BadgePainter(this.color, this.shape);
  final Color color;
  final BadgeShape shape;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    if (shape == BadgeShape.clover) {
      for (final offset in [
        const Offset(.33, .33),
        const Offset(.67, .33),
        const Offset(.33, .67),
        const Offset(.67, .67),
      ]) {
        canvas.drawCircle(
          Offset(size.width * offset.dx, size.height * offset.dy),
          size.width * .29,
          paint,
        );
      }
    } else {
      final path = Path();
      for (var i = 0; i < 6; i++) {
        final angle = math.pi / 3 * i - math.pi / 2;
        final x = size.width / 2 + math.cos(angle) * size.width * .43;
        final y = size.height / 2 + math.sin(angle) * size.height * .43;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(
        path,
        paint
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6,
      );
      canvas.drawPath(path, paint..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(covariant _BadgePainter old) =>
      old.color != color || old.shape != shape;
}

class RomanzaPreviewCard extends StatelessWidget {
  const RomanzaPreviewCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.color,
    required this.onTap,
    this.memory = false,
  });
  final String title, subtitle;
  final Widget leading;
  final Color color;
  final VoidCallback onTap;
  final bool memory;
  @override
  Widget build(BuildContext context) {
    final c = RomanzaColors.of(context);
    return Semantics(
      button: true,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(RomanzaSpace.radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: memory ? 68 : 64),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  leading,
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 12),
                      decoration: BoxDecoration(
                        border: Border(left: BorderSide(color: c.border)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: memory
                                ? RomanzaType.memory
                                : RomanzaType.card,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style:
                                (memory
                                        ? RomanzaType.caption
                                        : RomanzaType.body)
                                    .copyWith(color: c.secondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const ExcludeSemantics(
                    child: RomanzaIcon(RomanzaSymbol.arrowLeft, forward: true),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
