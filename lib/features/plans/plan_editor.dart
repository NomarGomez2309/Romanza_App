part of 'plans_screen.dart';

class _PlanEditor extends StatefulWidget {
  const _PlanEditor({required this.date, required this.id, this.existing});
  final DateTime date;
  final String id;
  final PlanDraft? existing;
  @override
  State<_PlanEditor> createState() => _PlanEditorState();
}

class _PlanEditorState extends State<_PlanEditor> {
  final form = GlobalKey<FormState>();
  late final title = TextEditingController(text: widget.existing?.title);
  late DateTime start =
      widget.existing?.start ??
      DateTime(widget.date.year, widget.date.month, widget.date.day, 19);
  late int minutes = widget.existing?.minutes ?? 60;
  late PlanKind kind = widget.existing?.kind ?? PlanKind.date;
  @override
  void dispose() {
    title.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: start,
      firstDate: DateTime(start.year - 100),
      lastDate: DateTime(start.year + 100),
    );
    if (!mounted || value == null) return;
    setState(
      () => start = DateTime(
        value.year,
        value.month,
        value.day,
        start.hour,
        start.minute,
      ),
    );
  }

  Future<void> pickTime() async {
    final value = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(start),
    );
    if (!mounted || value == null) return;
    setState(
      () => start = DateTime(
        start.year,
        start.month,
        start.day,
        value.hour,
        value.minute,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Form(
        key: form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.existing == null ? 'Un nuevo plan' : 'Editar plan',
              style: RomanzaType.section,
            ),
            const SizedBox(height: 8),
            const Text('Empiecen con algo sencillo.'),
            const SizedBox(height: 20),
            TextFormField(
              key: const ValueKey('plan-title'),
              controller: title,
              maxLength: 80,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: '¿Qué quieren hacer?',
                hintText: 'Una peli y algo rico',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(18)),
                ),
              ),
              validator: (value) => (value ?? '').trim().isEmpty
                  ? 'Ponle un nombre al plan.'
                  : null,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: pickDate,
              icon: const RomanzaIcon(RomanzaSymbol.calendarDays, size: 20),
              label: Text('${_date(start)} ${start.year}'),
            ),
            OutlinedButton(
              onPressed: pickTime,
              child: Text('Hora · ${_time(start)}'),
            ),
            const SizedBox(height: 12),
            const Text('Duración'),
            Wrap(
              spacing: 8,
              children: [
                for (final duration in [30, 60, 90, 120])
                  ChoiceChip(
                    label: Text('$duration min'),
                    selected: minutes == duration,
                    onSelected: (_) => setState(() => minutes = duration),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Tipo de plan'),
            Wrap(
              spacing: 8,
              children: [
                for (final value in PlanKind.values)
                  ChoiceChip(
                    label: Text(value.label),
                    selected: kind == value,
                    onSelected: (_) => setState(() => kind = value),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton(
              key: const ValueKey('save-plan'),
              onPressed: () {
                if (!form.currentState!.validate()) return;
                Navigator.pop(
                  context,
                  PlanDraft(
                    id: widget.id,
                    title: title.text.trim(),
                    start: start,
                    minutes: minutes,
                    kind: kind,
                    done: widget.existing?.done ?? false,
                  ),
                );
              },
              child: Text(
                widget.existing == null ? 'Crear borrador' : 'Guardar cambios',
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hora de este dispositivo. Borrador disponible durante esta sesión.',
              style: RomanzaType.caption,
            ),
          ],
        ),
      ),
    ),
  );
}
