import 'dart:math' as math;
import 'package:flutter/material.dart';

class HsvPicker extends StatelessWidget {
  const HsvPicker({
    super.key,
    required this.colors,
    required this.active,
    this.onChanged,
  });
  final List<Color?> colors;
  final int active;
  final ValueChanged<Color>? onChanged;
  static const center = Offset(106, 106);
  static const plane = Rect.fromLTWH(60, 60, 92, 92);
  void pick(Offset point) {
    if (onChanged == null) return;
    final hsv = HSVColor.fromColor(colors[active] ?? const Color(0xffff0000));
    final delta = point - center;
    if (plane.contains(point)) {
      onChanged!(
        hsv
            .withSaturation(((point.dx - plane.left) / plane.width).clamp(0, 1))
            .withValue((1 - (point.dy - plane.top) / plane.height).clamp(0, 1))
            .toColor(),
      );
    } else if (delta.distance >= 74 && delta.distance <= 106) {
      final hue = (math.atan2(delta.dy, delta.dx) * 180 / math.pi + 360) % 360;
      onChanged!(hsv.withHue(hue).toColor());
    }
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label:
        'Selector de tono, saturación y brillo. Color ${active + 1}. Usa Editar valores como alternativa al gesto.',
    child: GestureDetector(
      onPanDown: (d) => pick(d.localPosition),
      onPanUpdate: (d) => pick(d.localPosition),
      child: RepaintBoundary(
        child: CustomPaint(
          size: const Size(212, 212),
          painter: _HsvPainter(List.of(colors), active),
        ),
      ),
    ),
  );
}

class _HsvPainter extends CustomPainter {
  _HsvPainter(this.colors, this.active);
  final List<Color?> colors;
  final int active;
  @override
  void paint(Canvas canvas, Size size) {
    const center = HsvPicker.center;
    const plane = HsvPicker.plane;
    final hsv = HSVColor.fromColor(colors[active] ?? const Color(0xffff0000));
    final rainbow = SweepGradient(
      colors: [
        for (var h = 0; h <= 360; h += 30)
          HSVColor.fromAHSV(1, h.toDouble(), 1, 1).toColor(),
      ],
    );
    canvas.drawCircle(
      center,
      87,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 26
        ..shader = rainbow.createShader(
          Rect.fromCircle(center: center, radius: 100),
        ),
    );
    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(plane, const Radius.circular(8)));
    canvas.drawRect(
      plane,
      Paint()..color = HSVColor.fromAHSV(1, hsv.hue, 1, 1).toColor(),
    );
    canvas.drawRect(
      plane,
      Paint()
        ..shader = const LinearGradient(
          colors: [Colors.white, Colors.transparent],
        ).createShader(plane),
    );
    canvas.drawRect(
      plane,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black],
        ).createShader(plane),
    );
    canvas.restore();
    if (colors[active] != null) {
      final point = Offset(
        plane.left + hsv.saturation * plane.width,
        plane.bottom - hsv.value * plane.height,
      );
      canvas.drawCircle(
        point,
        6,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      canvas.drawCircle(
        point,
        6,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
    final hues = colors
        .map((c) => c == null ? null : HSVColor.fromColor(c).hue)
        .toList();
    final difference = hues[0] == null || hues[1] == null
        ? 180.0
        : (hues[0]! - hues[1]!).abs();
    final close = math.min(difference, 360 - difference) < 20;
    for (var i = 0; i < 2; i++) {
      if (hues[i] == null) continue;
      final angle = hues[i]! * math.pi / 180;
      final radius = close ? (i == 0 ? 94.0 : 70.0) : 87.0;
      final point = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      canvas.drawCircle(point, 12, Paint()..color = Colors.white);
      canvas.drawCircle(
        point,
        12,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = i == active ? 2 : 1,
      );
      final text = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(canvas, point - Offset(text.width / 2, text.height / 2));
      text.dispose();
    }
  }

  @override
  bool shouldRepaint(_HsvPainter old) =>
      old.active != active ||
      old.colors[0] != colors[0] ||
      old.colors[1] != colors[1];
}
