import 'dart:async';
import 'package:flutter/material.dart';
import '../../design_system/romanza_icon.dart';
import '../../design_system/romanza_theme.dart';
import 'important_date.dart';
import 'date_motion_surface.dart';

const _months = [
  'ENE',
  'FEB',
  'MAR',
  'ABR',
  'MAY',
  'JUN',
  'JUL',
  'AGO',
  'SEP',
  'OCT',
  'NOV',
  'DIC',
];

/// A reusable in-app date tile. This is not a native Android/iOS home widget.
class ImportantDateTile extends StatelessWidget {
  const ImportantDateTile({super.key, required this.entry, this.size = 84});
  final ImportantDate entry;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = RomanzaColors.of(context);
    final local = entry.date.toLocal();
    return Semantics(
      label: MaterialLocalizations.of(context).formatFullDate(local),
      child: ExcludeSemantics(
        child: Container(
          width: size * MediaQuery.textScalerOf(context).scale(12) / 12,
          height: size * MediaQuery.textScalerOf(context).scale(12) / 12,
          decoration: BoxDecoration(
            color: c.background,
            borderRadius: BorderRadius.circular(size >= 120 ? 24 : 20),
            border: Border.all(color: c.border),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${local.day}',
                  style: RomanzaType.heading(
                    size >= 120 ? 60 : 32,
                    size >= 120 ? 64 : 36,
                    600,
                  ).copyWith(color: c.ink),
                ),
                Text(
                  _months[local.month - 1],
                  style: RomanzaType.caption.copyWith(
                    color: c.secondary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UpcomingDateCard extends StatefulWidget {
  const UpcomingDateCard({
    super.key,
    required this.dates,
    required this.onTap,
    this.now,
  });
  final List<ImportantDate> dates;
  final VoidCallback onTap;
  final DateTime? now;

  @override
  State<UpcomingDateCard> createState() => _UpcomingDateCardState();
}

class _UpcomingDateCardState extends State<UpcomingDateCard>
    with WidgetsBindingObserver {
  Timer? _midnight;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _schedule();
  }

  void _schedule() {
    _midnight?.cancel();
    if (widget.now != null) return;
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    _midnight = Timer(tomorrow.difference(now), () {
      if (!mounted) return;
      setState(() {});
      _schedule();
    });
  }

  @override
  void didUpdateWidget(covariant UpcomingDateCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _schedule();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      setState(() {});
      _schedule();
    }
  }

  @override
  void dispose() {
    _midnight?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = widget.now ?? DateTime.now();
    final entry = nearestImportantDate(widget.dates, now);
    if (entry == null || entry.daysFrom(now) > 7) {
      return const SizedBox.shrink();
    }
    final c = RomanzaColors.of(context);
    final title = entry.title.trim().isEmpty
        ? 'Una fecha para ustedes'
        : entry.title;
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            RomanzaIcon(RomanzaSymbol.heart, size: 16, color: c.secondary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Un día especial',
                style: RomanzaType.caption.copyWith(color: c.secondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(title, style: RomanzaType.heading(20, 24, 600)),
        const SizedBox(height: 8),
        Row(
          children: [
            RomanzaIcon(
              RomanzaSymbol.calendarDays,
              size: 16,
              color: c.secondary,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                entry.countdown(now),
                style: RomanzaType.body.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Flexible(child: Text('Ver planes', style: RomanzaType.caption)),
            const SizedBox(width: 4),
            const RomanzaIcon(RomanzaSymbol.chevronRight, size: 16),
          ],
        ),
      ],
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Semantics(
        button: true,
        child: DateMotionSurface(
          identity: '${entry.id}-${entry.date}-${entry.countdown(now)}',
          radius: 24,
          onTap: widget.onTap,
          builder: (context, pressed) => Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final large = MediaQuery.textScalerOf(context).scale(14) > 21;
                final tile = AnimatedRotation(
                  turns: pressed ? -.008 : 0,
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 140),
                  child: ImportantDateTile(entry: entry),
                );
                if (large || constraints.maxWidth < 260) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [tile, const SizedBox(height: 12), text],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: text),
                    const SizedBox(width: 16),
                    tile,
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
