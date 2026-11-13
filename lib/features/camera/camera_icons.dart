import 'package:flutter/material.dart';

enum CameraGlyph { close, flashOn, flashOff, flip }

/// Paths transcribed from the supplied v4 SVG, without construction outlines.
class CameraControlIcon extends StatelessWidget {
  const CameraControlIcon(this.glyph, {super.key, this.enabled = true});
  final CameraGlyph glyph;
  final bool enabled;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      size: Size.square(glyph == CameraGlyph.close ? 24 : 28),
      painter: _GlyphPainter(
        glyph,
        (IconTheme.of(context).color ?? Theme.of(context).colorScheme.onSurface)
            .withValues(alpha: enabled ? 1 : .38),
      ),
    ),
  );
}

class _GlyphPainter extends CustomPainter {
  const _GlyphPainter(this.glyph, this.color);
  final CameraGlyph glyph;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path();
    if (glyph == CameraGlyph.close) {
      path
        ..moveTo(4, 4)
        ..lineTo(20, 20)
        ..moveTo(20, 4)
        ..lineTo(4, 20);
    } else if (glyph == CameraGlyph.flip) {
      canvas.scale(28 / 24);
      path
        ..moveTo(3, 10)
        ..arcToPoint(const Offset(20, 7), radius: const Radius.circular(9))
        ..moveTo(20, 2)
        ..lineTo(20, 8)
        ..lineTo(14, 8)
        ..moveTo(21, 14)
        ..arcToPoint(const Offset(4, 17), radius: const Radius.circular(9))
        ..moveTo(4, 22)
        ..lineTo(4, 16)
        ..lineTo(10, 16);
    } else {
      path
        ..moveTo(14, 0)
        ..lineTo(3, 15)
        ..lineTo(11, 15)
        ..lineTo(8, 26)
        ..lineTo(23, 10)
        ..lineTo(15, 10)
        ..close();
      if (glyph == CameraGlyph.flashOff) {
        path
          ..moveTo(2, 1)
          ..lineTo(25, 25);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _GlyphPainter oldDelegate) =>
      oldDelegate.glyph != glyph || oldDelegate.color != color;
}
