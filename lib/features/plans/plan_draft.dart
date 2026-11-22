part of 'plans_screen.dart';

const _months = [
  'Enero',
  'Febrero',
  'Marzo',
  'Abril',
  'Mayo',
  'Junio',
  'Julio',
  'Agosto',
  'Septiembre',
  'Octubre',
  'Noviembre',
  'Diciembre',
];
const _weekdays = [
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo',
];
String _time(DateTime date) =>
    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
String _date(DateTime d) => '${d.day} de ${_months[d.month - 1].toLowerCase()}';
DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

enum PlanKind {
  date('Cita', RomanzaSymbol.heart),
  home('En casa', RomanzaSymbol.house),
  out('Salida', RomanzaSymbol.calendarDays),
  distance('A distancia', RomanzaSymbol.link);

  const PlanKind(this.label, this.icon);
  final String label;
  final RomanzaSymbol icon;
}

@immutable
class PlanDraft {
  const PlanDraft({
    required this.id,
    required this.title,
    required this.start,
    this.minutes = 60,
    this.kind = PlanKind.date,
    this.done = false,
  });
  final String id, title;
  final DateTime start;
  final int minutes;
  final PlanKind kind;
  final bool done;
  DateTime get end => start.add(Duration(minutes: minutes));
  PlanDraft completed() => PlanDraft(
    id: id,
    title: title,
    start: start,
    minutes: minutes,
    kind: kind,
    done: !done,
  );
}
