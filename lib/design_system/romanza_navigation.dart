import 'dart:math' as math;
import 'dart:ui' show ImageFilter, lerpDouble;
import 'package:flutter/material.dart';
import 'romanza_icon.dart';
import 'romanza_theme.dart';

/// A single sliding selection surface inside a uniformly inset glass capsule.
/// Positions are interpolated from the current animation value, including when
/// a second tap redirects a transition before it has finished.
class RomanzaNavigation extends StatefulWidget {
  const RomanzaNavigation({
    super.key,
    required this.selected,
    required this.onSelect,
  }) : assert(selected >= 0 && selected < 3);
  final int selected;
  final ValueChanged<int> onSelect;
  @override
  State<RomanzaNavigation> createState() => _RomanzaNavigationState();
}

class _RomanzaNavigationState extends State<RomanzaNavigation>
    with SingleTickerProviderStateMixin {
  late final position = AnimationController.unbounded(
    vsync: this,
    value: widget.selected.toDouble(),
  );
  bool reduced = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    reduced = MediaQuery.disableAnimationsOf(context);
    if (reduced) {
      position.stop();
      position.value = widget.selected.toDouble();
    }
  }

  @override
  void didUpdateWidget(covariant RomanzaNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      if (reduced) {
        position.value = widget.selected.toDouble();
      } else {
        position.animateTo(
          widget.selected.toDouble(),
          duration: const Duration(milliseconds: 360),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  @override
  void dispose() {
    position.dispose();
    super.dispose();
  }

  static const labels = ['Hoy', 'Planes', 'Recuerdos'];
  static const icons = [
    RomanzaSymbol.romanzaHoy,
    RomanzaSymbol.calendarDays,
    RomanzaSymbol.romanzaRecuerdos,
  ];
  static const labelStyle = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w700,
  );

  @override
  Widget build(BuildContext context) {
    final c = RomanzaColors.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final contrast = MediaQuery.highContrastOf(context);
    final direction = Directionality.of(context);
    final scaler = MediaQuery.textScalerOf(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Align(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 448),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final available = constraints.maxWidth - 12;
                final natural = labels.map((label) {
                  final painter = TextPainter(
                    text: TextSpan(text: label, style: labelStyle),
                    textDirection: direction,
                    textScaler: scaler,
                  )..layout();
                  final width = math.max(
                    64.0,
                    painter.width.ceilToDouble() + 16,
                  );
                  painter.dispose();
                  return width;
                }).toList();
                final sum = natural.reduce((a, b) => a + b);
                final equal = available / 3;
                final slots = natural.every((w) => w <= equal)
                    ? List<double>.filled(3, equal)
                    : sum <= available
                    ? natural.map((w) => w + (available - sum) / 3).toList()
                    : natural
                          .map((w) => 48 + (w / sum) * (available - 144))
                          .toList();
                var innerHeight = 64.0;
                for (var i = 0; i < 3; i++) {
                  final painter = TextPainter(
                    text: TextSpan(text: labels[i], style: labelStyle),
                    textDirection: direction,
                    textScaler: scaler,
                  )..layout(maxWidth: math.max(1, slots[i] - 12));
                  innerHeight = math.max(
                    innerHeight,
                    24 + 4 + painter.height.ceilToDouble() + 12,
                  );
                  painter.dispose();
                }
                final shellHeight = innerHeight + 12;
                Widget shell = DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(36),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.alphaBlend(
                          Colors.white.withValues(alpha: dark ? .08 : .4),
                          c.background,
                        ).withValues(alpha: contrast ? 1 : .92),
                        c.background.withValues(alpha: contrast ? 1 : .8),
                      ],
                    ),
                    border: Border.all(
                      color: Color.lerp(
                        c.background,
                        c.ink,
                        contrast
                            ? .45
                            : dark
                            ? .25
                            : .16,
                      )!,
                      width: 1.1,
                    ),
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: AnimatedBuilder(
                        animation: position,
                        builder: (context, _) {
                          final value = position.value.clamp(0.0, 2.0);
                          final from = value.floor(), to = value.ceil();
                          double start(int index) => slots
                              .take(index)
                              .fold(0.0, (sum, width) => sum + width);
                          final left = lerpDouble(
                            start(from),
                            start(to),
                            value - from,
                          )!;
                          final width = lerpDouble(
                            slots[from],
                            slots[to],
                            value - from,
                          )!;
                          return Stack(
                            children: [
                              PositionedDirectional(
                                start: left,
                                top: 0,
                                width: width,
                                height: innerHeight,
                                child: IgnorePointer(
                                  child: DecoratedBox(
                                    key: const ValueKey('nav-selector'),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: contrast ? c.primary : null,
                                      gradient: contrast
                                          ? null
                                          : LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Color.alphaBlend(
                                                  c.primary.withValues(
                                                    alpha: dark ? .25 : .17,
                                                  ),
                                                  c.background,
                                                ),
                                                Color.alphaBlend(
                                                  c.primary.withValues(
                                                    alpha: dark ? .35 : .27,
                                                  ),
                                                  c.background,
                                                ),
                                              ],
                                            ),
                                      border: Border.all(
                                        color: contrast
                                            ? c.ink
                                            : Colors.white.withValues(
                                                alpha: dark ? .12 : .55,
                                              ),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: dark ? .12 : .035,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  for (var i = 0; i < 3; i++)
                                    SizedBox(
                                      width: slots[i],
                                      height: innerHeight,
                                      child: _NavigationItem(
                                        key: ValueKey('nav-item-$i'),
                                        index: i,
                                        label: labels[i],
                                        symbol: icons[i],
                                        selected: widget.selected == i,
                                        reduced: reduced,
                                        foreground:
                                            contrast && widget.selected == i
                                            ? c.onPrimary
                                            : widget.selected == i
                                            ? c.ink
                                            : c.secondary,
                                        focusColor: c.ink,
                                        onSelect: () => widget.onSelect(i),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                );
                if (!contrast) {
                  shell = BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: shell,
                  );
                }
                return DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(36),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: dark ? .22 : .08),
                        blurRadius: 22,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    height: shellHeight,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(36),
                      child: shell,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationItem extends StatefulWidget {
  const _NavigationItem({
    super.key,
    required this.index,
    required this.label,
    required this.symbol,
    required this.selected,
    required this.reduced,
    required this.foreground,
    required this.focusColor,
    required this.onSelect,
  });
  final int index;
  final String label;
  final RomanzaSymbol symbol;
  final bool selected, reduced;
  final Color foreground, focusColor;
  final VoidCallback onSelect;
  @override
  State<_NavigationItem> createState() => _NavigationItemState();
}

class _NavigationItemState extends State<_NavigationItem>
    with SingleTickerProviderStateMixin {
  late final impulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
    value: 1,
  );
  bool pressed = false, focused = false;
  void pulseIcon() {
    if (!widget.reduced) {
      impulse.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(covariant _NavigationItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reduced) {
      impulse.stop();
      impulse.value = 1;
    } else if (widget.selected && !oldWidget.selected) {
      pulseIcon();
    }
  }

  @override
  void dispose() {
    impulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duration = widget.reduced
        ? Duration.zero
        : const Duration(milliseconds: 100);
    return Semantics(
      label: widget.label,
      selected: widget.selected,
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        splashFactory: NoSplash.splashFactory,
        focusColor: widget.focusColor.withValues(alpha: .09),
        hoverColor: widget.focusColor.withValues(alpha: .04),
        highlightColor: widget.focusColor.withValues(alpha: .07),
        onFocusChange: (value) => setState(() => focused = value),
        onHighlightChanged: (value) => setState(() => pressed = value),
        onTap: () {
          pulseIcon();
          widget.onSelect();
        },
        child: ExcludeSemantics(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                width: 1.5,
                color: focused
                    ? widget.focusColor.withValues(alpha: .65)
                    : Colors.transparent,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedScale(
                    key: ValueKey('nav-press-${widget.index}'),
                    scale: pressed && !widget.reduced ? .92 : 1,
                    duration: duration,
                    curve: Curves.easeOutCubic,
                    child: AnimatedBuilder(
                      animation: impulse,
                      builder: (context, child) {
                        final lift = widget.reduced
                            ? 0.0
                            : math.sin(math.pi * impulse.value);
                        return Transform.translate(
                          key: ValueKey('nav-lift-${widget.index}'),
                          offset: Offset(0, -3 * lift),
                          child: Transform.rotate(
                            angle: widget.reduced
                                ? 0
                                : math.sin(2 * math.pi * impulse.value) * .06,
                            child: AnimatedScale(
                              scale: widget.selected && !widget.reduced
                                  ? 1.08
                                  : 1,
                              duration: widget.reduced
                                  ? Duration.zero
                                  : const Duration(milliseconds: 180),
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: RomanzaIcon(
                        widget.symbol,
                        size: 24,
                        color: widget.foreground,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: _RomanzaNavigationState.labelStyle.copyWith(
                      color: widget.foreground,
                    ),
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
