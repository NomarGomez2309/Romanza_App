import 'package:flutter/material.dart';
import '../../design_system/romanza_theme.dart';

/// One-shot entrance and touch feedback; never runs a repeating animation.
class DateMotionSurface extends StatefulWidget {
  const DateMotionSurface({
    super.key,
    required this.identity,
    required this.radius,
    required this.builder,
    this.onTap,
  });
  final Object identity;
  final double radius;
  final Widget Function(BuildContext, bool) builder;
  final VoidCallback? onTap;

  @override
  State<DateMotionSurface> createState() => _DateMotionSurfaceState();
}

class _DateMotionSurfaceState extends State<DateMotionSurface> {
  bool pressed = false;
  @override
  void didUpdateWidget(covariant DateMotionSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.identity != widget.identity || widget.onTap == null) {
      pressed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = RomanzaColors.of(context);
    final reduced = MediaQuery.disableAnimationsOf(context);
    return TweenAnimationBuilder<double>(
      key: ValueKey(widget.identity),
      tween: Tween(begin: reduced ? 1 : 0, end: 1),
      duration: reduced ? Duration.zero : const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: reduced ? 1 : value,
        child: Transform.translate(
          offset: Offset(0, reduced ? 0 : 4 * (1 - value)),
          child: child,
        ),
      ),
      child: AnimatedScale(
        scale: pressed && !reduced ? .985 : 1,
        duration: reduced ? Duration.zero : const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: Material(
          color: c.note,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.radius),
            side: BorderSide(color: c.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            onHighlightChanged: (value) {
              if (pressed != value) setState(() => pressed = value);
            },
            splashFactory: reduced ? NoSplash.splashFactory : null,
            child: widget.builder(context, pressed && !reduced),
          ),
        ),
      ),
    );
  }
}
