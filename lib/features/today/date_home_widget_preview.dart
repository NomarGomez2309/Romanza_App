import 'package:flutter/material.dart';
import '../../design_system/romanza_icon.dart';
import '../../design_system/romanza_theme.dart';
import 'important_date.dart';

/// Visual specification for a future native home-screen widget.
/// Does not register a WidgetKit/AppWidget provider or access device storage.
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

  @override
  Widget build(BuildContext context) {
    final c = RomanzaColors.of(context);
    final date = entry?.date.toLocal();
    return Material(
      color: c.note,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: c.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const RomanzaIcon(RomanzaSymbol.heart, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Próxima fecha',
                      style: RomanzaType.time.copyWith(color: c.secondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (date != null)
                Text(
                  MaterialLocalizations.of(context).formatShortMonthDay(date),
                  style: RomanzaType.heading(30, 36, 600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  entry?.title ?? 'Sus próximos días especiales',
                  style: RomanzaType.card,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                entry == null ? 'Abrir Romanza' : entry!.countdown(now),
                style: RomanzaType.time.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
