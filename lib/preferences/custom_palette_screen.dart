import 'package:flutter/material.dart';
import '../design_system/components.dart';
import '../design_system/romanza_theme.dart';
import '../design_system/romanza_icon.dart';
import 'custom_palette.dart';
import 'palette_controller.dart';
import 'preferences_screen.dart';
import 'hsv_picker.dart';

class CustomPaletteScreen extends StatefulWidget {
  const CustomPaletteScreen({super.key, required this.controller});
  final PaletteController controller;
  @override
  State<CustomPaletteScreen> createState() => _CustomPaletteScreenState();
}

class _CustomPaletteScreenState extends State<CustomPaletteScreen> {
  final List<Color?> seeds = [null, null];
  int active = 0;
  List<CustomPalette> proposals = [];
  int? selected;
  bool generating = false;
  String? error;
  void change(Color value) => setState(() {
    seeds[active] = value;
    proposals = [];
    selected = null;
    error = null;
  });
  Future<void> edit() async {
    final index = active;
    var hsv = HSVColor.fromColor(seeds[index] ?? const Color(0xffff0000));
    final input = TextEditingController(
      text: seeds[index] == null
          ? ''
          : seeds[index]!
                .toARGB32()
                .toRadixString(16)
                .substring(2)
                .toUpperCase(),
    );
    String? validation;
    final value = await showDialog<Color>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          title: Text('Color ${index + 1}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: input,
                  onChanged: (raw) {
                    if (RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(raw.trim())) {
                      update(() {
                        hsv = HSVColor.fromColor(
                          Color(int.parse('ff${raw.trim()}', radix: 16)),
                        );
                        validation = null;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Código hexadecimal',
                    prefixText: '#',
                    errorText: validation,
                  ),
                  maxLength: 6,
                ),
                for (var i = 0; i < 3; i++) ...[
                  Text(['Tono', 'Saturación', 'Brillo'][i]),
                  Slider(
                    label: i == 0
                        ? '${hsv.hue.round()}°'
                        : '${((i == 1 ? hsv.saturation : hsv.value) * 100).round()}%',
                    value: [hsv.hue / 360, hsv.saturation, hsv.value][i],
                    semanticFormatterCallback: (v) => i == 0
                        ? '${(v * 360).round()} grados'
                        : '${(v * 100).round()} por ciento',
                    onChanged: (v) => update(() {
                      hsv = i == 0
                          ? hsv.withHue(v * 360)
                          : i == 1
                          ? hsv.withSaturation(v)
                          : hsv.withValue(v);
                      input.text = hsv
                          .toColor()
                          .toARGB32()
                          .toRadixString(16)
                          .substring(2)
                          .toUpperCase();
                      validation = null;
                    }),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final raw = input.text.trim();
                if (!RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(raw)) {
                  update(
                    () => validation =
                        'Introduce seis caracteres de 0 a 9 o A a F.',
                  );
                  return;
                }
                Navigator.pop(context, Color(int.parse('ff$raw', radix: 16)));
              },
              child: const Text('Aplicar'),
            ),
          ],
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 300));
    input.dispose();
    if (mounted && value != null) {
      active = index;
      change(value);
    }
  }

  Future<void> generate() async {
    if (generating || seeds.any((c) => c == null)) return;
    setState(() {
      generating = true;
      error = null;
    });
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;
    try {
      final next = generatePalettes(seeds[0]!, seeds[1]!);
      if (next.length != 3 || next.map((p) => p.id).toSet().length != 3) {
        throw StateError('Duplicate proposals');
      }
      setState(() {
        proposals = next;
        selected = null;
        generating = false;
      });
    } catch (_) {
      setState(() {
        generating = false;
        error = 'No pudimos generar las paletas. Puedes reintentar.';
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('Crea tu paleta', style: RomanzaType.heading(26, 32, 500)),
    ),
    body: SafeArea(
      top: false,
      child: RomanzaPage(
        child: ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) {
            final c = RomanzaColors.of(context);
            final busy = generating || widget.controller.saving;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Elige dos colores para empezar',
                  style: RomanzaType.body.copyWith(
                    fontSize: 16,
                    height: 24 / 16,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < 2; i++) ...[
                      if (i > 0) const SizedBox(width: 12),
                      Expanded(
                        child: Semantics(
                          selected: active == i,
                          value: seeds[i] == null
                              ? 'Sin elegir'
                              : 'Color elegido',
                          child: OutlinedButton(
                            onPressed: busy
                                ? null
                                : () => setState(() => active = i),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              side: BorderSide(
                                color: active == i ? c.primary : c.border,
                                width: active == i ? 2 : 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: seeds[i] ?? c.note,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${i + 1}',
                                          style: TextStyle(
                                            color: seeds[i] == null
                                                ? c.ink
                                                : CustomPalette.readable(
                                                    seeds[i]!,
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text('Color ${i + 1}')),
                                    if (active == i)
                                      RomanzaIcon(
                                        RomanzaSymbol.check,
                                        size: 18,
                                        color: c.ink,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 22),
                Center(
                  child: HsvPicker(
                    colors: seeds,
                    active: active,
                    onChanged: busy ? null : change,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Toca o arrastra el color activo',
                  textAlign: TextAlign.center,
                  style: RomanzaType.body,
                ),
                Center(
                  child: TextButton(
                    onPressed: busy ? null : edit,
                    child: Text('Editar valores de Color ${active + 1}'),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: busy || seeds.any((c) => c == null)
                      ? null
                      : generate,
                  child: Text(error == null ? 'Generar paletas' : 'Reintentar'),
                ),
                if (generating)
                  const LinearProgressIndicator(
                    semanticsLabel: 'Generando paletas',
                  ),
                if (error != null)
                  Semantics(liveRegion: true, child: Text(error!)),
                const SizedBox(height: 24),
                if (proposals.isNotEmpty) ...[
                  Text(
                    'Elige una propuesta',
                    style: RomanzaType.heading(22, 28, 500),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < 3; i++) ...[
                        if (i > 0) const SizedBox(width: 8),
                        Expanded(
                          child: PaletteSample(
                            palette: proposals[i],
                            label: 'Propuesta ${i + 1}',
                            selected: selected == i,
                            onTap: busy
                                ? null
                                : () => setState(() => selected = i),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
                FilledButton(
                  onPressed: selected == null || busy
                      ? null
                      : () async {
                          final saved = await widget.controller.saveCustom(
                            proposals[selected!],
                          );
                          if (context.mounted && saved) Navigator.pop(context);
                        },
                  child: const Text('Guardar paleta'),
                ),
                if (widget.controller.saving)
                  const LinearProgressIndicator(
                    semanticsLabel: 'Guardando tema',
                  ),
                if (widget.controller.error != null)
                  Semantics(
                    liveRegion: true,
                    child: Text(widget.controller.error!),
                  ),
                const SizedBox(height: 16),
                Text(
                  'Se guarda en este dispositivo.',
                  style: RomanzaType.caption.copyWith(color: c.secondary),
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}
