import 'package:flutter/material.dart';
import '../../design_system/components.dart';
import '../../design_system/romanza_icon.dart';
import '../../design_system/romanza_theme.dart';

part 'plan_draft.dart';
part 'plan_editor.dart';

/// Interactive design prototype. Drafts belong to this widget's session;
/// no remote data, fictitious partner, reminders or shared persistence.
class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key, this.initialPlans = const [], this.now});
  final List<PlanDraft> initialPlans;
  final DateTime? now;
  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  late DateTime selected = _day(widget.now ?? DateTime.now());
  late List<PlanDraft> plans = [...widget.initialPlans];
  bool calendar = false;
  bool monthExpanded = false;
  int serial = 0;
  Duration get motion => MediaQuery.disableAnimationsOf(context)
      ? Duration.zero
      : const Duration(milliseconds: 200);
  List<PlanDraft> get today =>
      plans.where((p) => _sameDay(p.start, selected)).toList()
        ..sort((a, b) => a.start.compareTo(b.start));
  List<PlanDraft> get month =>
      plans
          .where(
            (p) =>
                p.start.year == selected.year &&
                p.start.month == selected.month,
          )
          .toList()
        ..sort((a, b) => a.start.compareTo(b.start));

  Future<void> edit([PlanDraft? existing]) async {
    final result = await showModalBottomSheet<PlanDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _PlanEditor(
        date: selected,
        existing: existing,
        id:
            existing?.id ??
            'draft-${DateTime.now().microsecondsSinceEpoch}-${serial++}',
      ),
    );
    if (!mounted || result == null) return;
    setState(() {
      plans.removeWhere((p) => p.id == result.id);
      plans.add(result);
      selected = _day(result.start);
    });
  }

  Future<void> details(PlanDraft plan) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        final c = RomanzaColors.of(context);
        return SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  plan.kind.label,
                  style: RomanzaType.body.copyWith(color: c.secondary),
                ),
                const SizedBox(height: 8),
                Text(plan.title, style: RomanzaType.greeting),
                const SizedBox(height: 16),
                Text(
                  '${_date(plan.start)} · ${_time(plan.start)}–${_time(plan.end)}',
                ),
                const SizedBox(height: 8),
                Text(
                  'Hora de este dispositivo · Borrador de sesión',
                  style: RomanzaType.caption,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.pop(context, 'done'),
                  child: Text(
                    plan.done
                        ? 'Marcar como pendiente'
                        : 'Marcar como realizado',
                  ),
                ),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context, 'edit'),
                  child: const Text('Editar plan'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, 'delete'),
                  child: const Text('Eliminar borrador'),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (!mounted || action == null) return;
    if (action == 'edit') {
      await edit(plan);
      return;
    }
    setState(() {
      plans.removeWhere((p) => p.id == plan.id);
      if (action == 'done') plans.add(plan.completed());
    });
    if (action == 'delete') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Borrador eliminado'),
          action: SnackBarAction(
            label: 'Deshacer',
            onPressed: () {
              if (mounted) setState(() => plans.add(plan));
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = RomanzaColors.of(context);
    return RomanzaPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text('Planes', style: RomanzaType.greeting),
                ),
              ),
              IconButton.filled(
                key: const ValueKey('new-plan'),
                tooltip: 'Crear un plan',
                onPressed: edit,
                style: IconButton.styleFrom(
                  backgroundColor: c.primary,
                  foregroundColor: c.onPrimary,
                  minimumSize: const Size(52, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                icon: const RomanzaIcon(RomanzaSymbol.plus),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Algo bonito por hacer, juntos.',
            style: RomanzaType.days.copyWith(color: c.secondary),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              for (final value in [false, true]) ...[
                if (value) const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => calendar = value),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: calendar == value
                          ? c.ink
                          : Colors.transparent,
                      foregroundColor: calendar == value ? c.background : c.ink,
                      side: BorderSide(
                        color: calendar == value ? c.ink : c.border,
                      ),
                      shape: const StadiumBorder(),
                    ),
                    child: Semantics(
                      selected: calendar == value,
                      child: Text(value ? 'Calendario' : 'Día'),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          AnimatedSize(
            duration: motion,
            alignment: Alignment.topCenter,
            child: calendar ? _calendar(c) : _dayHeader(c),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  calendar ? 'Este mes, juntos' : 'Su día, a su ritmo',
                  style: RomanzaType.section,
                ),
              ),
              if ((calendar ? month : today).isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    '${(calendar ? month : today).length}',
                    style: RomanzaType.days,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if ((calendar ? month : today).isEmpty)
            RomanzaEmptyState(
              icon: RomanzaSymbol.calendarDays,
              title: 'Dejen un hueco para ustedes',
              message: calendar
                  ? 'Este mes puede empezar con un plan sencillo.'
                  : 'Todavía no hay planes. No hace falta una gran ocasión para compartir un rato.',
              action: OutlinedButton(
                onPressed: edit,
                child: const Text('Crear un plan'),
              ),
            )
          else if (!calendar)
            for (final plan in today)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _card(plan, c),
              )
          else
            for (var i = 0; i < month.length; i++) ...[
              if (i == 0 || !_sameDay(month[i - 1].start, month[i].start))
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 10),
                  child: Text(
                    '${_weekdays[month[i].start.weekday - 1]} · ${_date(month[i].start)}',
                    style: RomanzaType.days.copyWith(color: c.secondary),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _card(month[i], c),
              ),
            ],
          const SizedBox(height: 12),
          Text(
            'Vista de diseño · Los borradores duran esta sesión.',
            textAlign: TextAlign.center,
            style: RomanzaType.caption.copyWith(color: c.secondary),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _dayHeader(RomanzaColors c) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              _weekdays[selected.weekday - 1],
              style: RomanzaType.days.copyWith(color: c.secondary),
            ),
          ),
          _arrow(
            'Día anterior',
            () => setState(
              () => selected = DateTime(
                selected.year,
                selected.month,
                selected.day - 1,
              ),
            ),
            false,
          ),
          _arrow(
            'Día siguiente',
            () => setState(
              () => selected = DateTime(
                selected.year,
                selected.month,
                selected.day + 1,
              ),
            ),
            true,
          ),
        ],
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            flex: 3,
            child: Text(
              '${selected.day.toString().padLeft(2, '0')}\n${_months[selected.month - 1].substring(0, 3).toUpperCase()}',
              style: RomanzaType.heading(58, 58, 500).copyWith(color: c.ink),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.only(left: 20),
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: c.border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const RomanzaIcon(RomanzaSymbol.romanzaVinculo, size: 28),
                  const SizedBox(height: 8),
                  Text(
                    'Un rato\npara ustedes',
                    style: RomanzaType.card.copyWith(fontSize: 19, height: 1.2),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${today.where((p) => !p.done).length} pendientes',
                    style: RomanzaType.caption.copyWith(color: c.secondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          onPressed: () =>
              setState(() => selected = _day(widget.now ?? DateTime.now())),
          child: const Text('Ir a hoy'),
        ),
      ),
    ],
  );

  Widget _calendar(RomanzaColors c) {
    final first = DateTime(selected.year, selected.month);
    final days = DateTime(selected.year, selected.month + 1, 0).day;
    final offset = first.weekday - 1;
    final cells = ((offset + days + 6) ~/ 7) * 7;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.memory,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _arrow(
                'Mes anterior',
                () => setState(
                  () => selected = DateTime(selected.year, selected.month - 1),
                ),
                false,
              ),
              Expanded(
                child: Text(
                  '${_months[selected.month - 1]} ${selected.year}',
                  textAlign: TextAlign.center,
                  style: RomanzaType.card,
                ),
              ),
              _arrow(
                'Mes siguiente',
                () => setState(
                  () => selected = DateTime(selected.year, selected.month + 1),
                ),
                true,
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (var row = -1; row < (monthExpanded ? cells ~/ 7 : 1); row++)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var col = 0; col < 7; col++)
                  Expanded(
                    child: row == -1
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              ['L', 'M', 'X', 'J', 'V', 'S', 'D'][col],
                              textAlign: TextAlign.center,
                              style: RomanzaType.caption,
                            ),
                          )
                        : Builder(
                            builder: (context) {
                              final number = monthExpanded
                                  ? row * 7 + col - offset + 1
                                  : selected.day - selected.weekday + 1 + col;
                              if (number < 1 || number > days) {
                                return const SizedBox(height: 48);
                              }
                              final day = DateTime(
                                selected.year,
                                selected.month,
                                number,
                              );
                              final active = _sameDay(day, selected);
                              final marked = plans.any(
                                (p) => _sameDay(p.start, day),
                              );
                              return Semantics(
                                selected: active,
                                label:
                                    '${_date(day)} ${day.year}${marked ? ', con planes' : ''}',
                                button: true,
                                child: InkWell(
                                  key: ValueKey('plan-day-$number'),
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () => setState(() {
                                    selected = day;
                                    calendar = false;
                                  }),
                                  child: ExcludeSemantics(
                                    child: Container(
                                      constraints: const BoxConstraints(
                                        minHeight: 48,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 7,
                                      ),
                                      decoration: BoxDecoration(
                                        color: active
                                            ? c.primary
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            '$number',
                                            style: RomanzaType.body.copyWith(
                                              color: active
                                                  ? c.onPrimary
                                                  : c.ink,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Container(
                                            width: 4,
                                            height: 4,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: marked
                                                  ? (active
                                                        ? c.onPrimary
                                                        : c.secondary)
                                                  : Colors.transparent,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
              ],
            ),
          TextButton(
            onPressed: () => setState(() => monthExpanded = !monthExpanded),
            child: Text(monthExpanded ? 'Cerrar mes' : 'Ver todo el mes'),
          ),
        ],
      ),
    );
  }

  Widget _arrow(String label, VoidCallback action, bool forward) => IconButton(
    tooltip: label,
    onPressed: action,
    icon: RomanzaIcon(RomanzaSymbol.arrowLeft, size: 20, forward: forward),
  );

  Widget _card(PlanDraft plan, RomanzaColors c) {
    final background = switch (plan.kind) {
      PlanKind.date => c.plan,
      PlanKind.home => c.note,
      PlanKind.out => c.memory,
      PlanKind.distance => c.note,
    };
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        key: ValueKey('plan-${plan.id}'),
        onTap: () => details(plan),
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      plan.title,
                      style: RomanzaType.section.copyWith(
                        fontSize: 26,
                        height: 1.12,
                        decoration: plan.done
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  RomanzaBadge(
                    icon: plan.done ? RomanzaSymbol.check : plan.kind.icon,
                    shape: BadgeShape.hexagon,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                plan.done ? 'Realizado · ${plan.kind.label}' : plan.kind.label,
                style: RomanzaType.caption.copyWith(color: c.secondary),
              ),
              const SizedBox(height: 18),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  _clock('Inicio', _time(plan.start), c),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: c.background.withValues(alpha: .65),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Text(
                        '${plan.minutes} min',
                        style: RomanzaType.caption,
                      ),
                    ),
                  ),
                  _clock(
                    _sameDay(plan.start, plan.end)
                        ? 'Fin'
                        : 'Fin · ${_date(plan.end)}',
                    _time(plan.end),
                    c,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _clock(String label, String value, RomanzaColors c) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(value, style: RomanzaType.heading(24, 28, 500)),
      const SizedBox(height: 2),
      Text(label, style: RomanzaType.caption.copyWith(color: c.secondary)),
    ],
  );
}
