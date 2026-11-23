import 'package:flutter/material.dart';
import '../../design_system/romanza_icon.dart';
import '../../design_system/romanza_theme.dart';
import 'important_date.dart';
import 'date_motion_surface.dart';

/// Visual specification only; does not register AppWidget or WidgetKit.
class DateHomeWidgetPreview extends StatelessWidget {
  const DateHomeWidgetPreview({
    super.key,
    required this.entry,
    required this.now,
    this.onTap,
  });
  final ImportantDate? entry;
  final DateTime now;
  final VoidCallback? onTap;
  static const months = [
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

  @override
  Widget build(BuildContext context) {
    final c = RomanzaColors.of(context);
    final active = entry != null && entry!.daysFrom(now) >= 0 ? entry : null;
    final date = active?.date.toLocal();
    final title = active?.title.trim();
    return DateMotionSurface(
      identity: '${active?.id}-${date?.toIso8601String()}',
      radius: 28,
      onTap: onTap,
      builder: (context, pressed) => Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    right: 12,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: date == null
                          ? RomanzaIcon(
                              RomanzaSymbol.calendarDays,
                              size: 44,
                              color: c.secondary,
                            )
                          : Semantics(
                              label: MaterialLocalizations.of(
                                context,
                              ).formatFullDate(date),
                              child: ExcludeSemantics(
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  alignment: Alignment.topLeft,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}',
                                        style: RomanzaType.heading(44, 44, 500)
                                            .copyWith(
                                              color: c.ink,
                                              letterSpacing: -1.4,
                                            ),
                                      ),
                                      Text(
                                        months[date.month - 1],
                                        style: RomanzaType.heading(42, 42, 500)
                                            .copyWith(
                                              color: c.ink,
                                              letterSpacing: -.8,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: RomanzaIcon(
                      RomanzaSymbol.heart,
                      size: 14,
                      color: c.secondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title == null || title.isEmpty ? 'Sus días especiales' : title,
              style: RomanzaType.card,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                RomanzaIcon(
                  RomanzaSymbol.calendarDays,
                  size: 12,
                  color: c.secondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    active == null ? 'Abrir Romanza' : active.countdown(now),
                    style: RomanzaType.time.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
