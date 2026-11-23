import 'package:flutter/foundation.dart';

/// An explicitly supplied occasion, not an inferred anniversary or a plan draft.
@immutable
class ImportantDate {
  const ImportantDate({
    required this.id,
    required this.title,
    required this.date,
  });
  final String id, title;
  final DateTime date;

  /// Calendar days, rather than elapsed 24-hour periods (DST-safe).
  int daysFrom(DateTime now) {
    final local = date.toLocal();
    final today = now.toLocal();
    return DateTime.utc(
      local.year,
      local.month,
      local.day,
    ).difference(DateTime.utc(today.year, today.month, today.day)).inDays;
  }

  String countdown(DateTime now) => switch (daysFrom(now)) {
    0 => 'Es hoy',
    1 => 'Mañana',
    final days => 'En $days días',
  };
}

ImportantDate? nearestImportantDate(
  Iterable<ImportantDate> dates,
  DateTime now,
) {
  final upcoming = dates.where((entry) => entry.daysFrom(now) >= 0).toList()
    ..sort((a, b) {
      final days = a.daysFrom(now).compareTo(b.daysFrom(now));
      return days != 0 ? days : a.id.compareTo(b.id);
    });
  return upcoming.isEmpty ? null : upcoming.first;
}
