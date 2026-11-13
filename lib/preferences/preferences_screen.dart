import 'package:romanza/design_system/romanza_icon.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../design_system/components.dart';
import '../design_system/romanza_theme.dart';
import 'custom_palette.dart';
import 'palette_controller.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key, required this.controller});
  final PaletteController controller;
  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final seeds = [const Color(0xff9fa0ff), const Color(0xffff7171)];
  int active = 0;
  List<CustomPalette> proposals = [];
  int? selected;
  @override
  void initState() {
    super.initState();
    final current =
        widget.controller.custom?.theme ??
        RomanzaColors.forPalette(widget.controller.palette);
    seeds[0] = current.primary;
    seeds[1] = current.accent;
  }

  void change(Color value) => setState(() {
    seeds[active] = value;
    proposals = [];
    selected = null;
  });
  Future<void> edit(int index) async {
    setState(() => active = index);
    final input = TextEditingController(
      text: seeds[index]
          .toARGB32()
          .toRadixString(16)
          .substring(2)
          .toUpperCase(),
    );
    String? error;
    final value = await showDialog<Color>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          title: Text('Color ${index + 1}'),
          content: TextField(
            controller: input,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Código hexadecimal',
              prefixText: '#',
              errorText: error,
            ),
            maxLength: 6,
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
                    () => error = 'Introduce seis caracteres de 0 a 9 o A a F.',
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
    // The dialog's exit animation may still use its editing controller.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    input.dispose();
    if (mounted && value != null) change(value);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Preferencias')),
    body: SafeArea(
      top: false,
      child: RomanzaPage(
        child: ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) {
            final controller = widget.controller;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Paleta de color',
                  style: RomanzaType.heading(21, 28, 500),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final palette in RomanzaPalette.values)
                      ChoiceChip(
                        showCheckmark: false,
                        avatar:
                            controller.custom == null &&
                                controller.palette == palette
                            ? RomanzaIcon(
                                RomanzaSymbol.check,
                                size: 24,
                                color: RomanzaColors.of(context).onPrimary,
                              )
                            : null,
                        label: Text(palette.label),
                        shape: const StadiumBorder(),
                        selectedColor: RomanzaColors.of(context).primary,
                        labelStyle: TextStyle(
                          color:
                              controller.custom == null &&
                                  controller.palette == palette
                              ? RomanzaColors.of(context).onPrimary
                              : RomanzaColors.of(context).ink,
                        ),
                        selected:
                            controller.custom == null &&
                            controller.palette == palette,
                        onSelected: controller.saving
                            ? null
                            : (_) => controller.select(palette),
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Crea tu paleta', style: RomanzaType.heading(21, 28, 500)),
                const SizedBox(height: 20),
                Center(
                  child: Semantics(
                    label:
                        'Rueda cromática. Edita Color 1 o Color 2 para introducir un código exacto.',
                    child: GestureDetector(
                      onPanDown: (d) {
                        for (var i = 0; i < 2; i++) {
                          if ((d.localPosition - _Wheel.handle(seeds, i))
                                  .distance <=
                              24) {
                            setState(() => active = i);
                            break;
                          }
                        }
                        pick(d.localPosition);
                      },
                      onPanUpdate: (d) => pick(d.localPosition),
                      child: CustomPaint(
                        size: const Size(208, 208),
                        painter: _Wheel(
                          seeds,
                          active,
                          RomanzaColors.of(context).background,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < 2; i++)
                      OutlinedButton.icon(
                        onPressed: () => edit(i),
                        icon: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: seeds[i],
                            border: Border.all(
                              color: RomanzaColors.of(context).ink,
                            ),
                          ),
                        ),
                        label: Text('Color ${i + 1}'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => setState(() {
                    proposals = generatePalettes(seeds[0], seeds[1]);
                    selected = null;
                  }),
                  child: const Text('Generar paletas'),
                ),
                const SizedBox(height: 16),
                if (proposals.isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < 3; i++)
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: i == 2 ? 0 : 8),
                            child: Column(
                              children: [
                                PaletteSample(
                                  palette: proposals[i],
                                  label: 'Propuesta ${i + 1}',
                                  selected: selected == i,
                                  onTap: () => setState(() => selected = i),
                                ),
                                Text('${i + 1}', style: RomanzaType.caption),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: selected == null || controller.saving
                      ? null
                      : () async {
                          final saved = await controller.saveCustom(
                            proposals[selected!],
                          );
                          if (context.mounted && saved) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Paleta guardada en este dispositivo',
                                ),
                              ),
                            );
                          }
                        },
                  child: const Text('Guardar paleta'),
                ),
                if (controller.saving)
                  const LinearProgressIndicator(
                    semanticsLabel: 'Guardando preferencias',
                  ),
                if (controller.error != null)
                  Semantics(liveRegion: true, child: Text(controller.error!)),
                if (controller.bank.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text('Tus paletas', style: RomanzaType.section),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (var i = 0; i < controller.bank.length; i++)
                        SizedBox(
                          width: 110,
                          child: PaletteSample(
                            palette: controller.bank[i],
                            label: 'Paleta guardada ${i + 1}',
                            selected:
                                controller.activeCustomId ==
                                controller.bank[i].id,
                            onTap: controller.saving
                                ? null
                                : () =>
                                      controller.saveCustom(controller.bank[i]),
                          ),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  'Se guarda en este dispositivo.',
                  style: RomanzaType.caption,
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
  void pick(Offset point) {
    final delta = point - const Offset(104, 104);
    if (delta.distance < 57 || delta.distance > 104) return;
    final hue = (math.atan2(delta.dy, delta.dx) * 180 / math.pi + 360) % 360;
    change(HSVColor.fromAHSV(1, hue, 1, 1).toColor());
  }
}

class PaletteSample extends StatelessWidget {
  const PaletteSample({
    super.key,
    required this.palette,
    required this.label,
    required this.selected,
    this.onTap,
  });
  final CustomPalette palette;
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: label,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 64,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? RomanzaColors.of(context).ink
                : RomanzaColors.of(context).border,
            width: selected ? 2 : 1,
          ),
        ),
        child: ExcludeSemantics(
          child: Stack(
            children: [
              Row(
                children: [
                  for (final color in palette.colors)
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                ],
              ),
              if (selected)
                Align(
                  alignment: Alignment.center,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: RomanzaColors.of(context).background,
                      shape: BoxShape.circle,
                    ),
                    child: const RomanzaIcon(RomanzaSymbol.check, size: 20),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Wheel extends CustomPainter {
  _Wheel(this.colors, this.active, this.background);
  final List<Color> colors;
  final int active;
  final Color background;
  static Offset handle(List<Color> colors, int index) {
    final first = HSVColor.fromColor(colors[0]).hue;
    final second = HSVColor.fromColor(colors[1]).hue;
    final distance = (first - second).abs();
    final near = math.min(distance, 360 - distance) < 20;
    final angle = HSVColor.fromColor(colors[index]).hue * math.pi / 180;
    return const Offset(104, 104) +
        Offset(math.cos(angle), math.sin(angle)) *
            (near ? (index == 0 ? 90 : 60) : 80);
  }

  @override
  void paint(Canvas canvas, Size size) {
    const center = Offset(104, 104);
    final gradient = SweepGradient(
      colors: [
        for (var h = 0; h <= 360; h += 30)
          HSVColor.fromAHSV(1, h.toDouble(), 1, 1).toColor(),
      ],
    );
    canvas.drawCircle(
      center,
      94,
      Paint()
        ..shader = gradient.createShader(const Rect.fromLTWH(10, 10, 188, 188)),
    );
    canvas.drawCircle(center, 57, Paint()..color = background);
    for (var i = 0; i < 2; i++) {
      final point = handle(colors, i);
      canvas.drawCircle(point, 14, Paint()..color = Colors.white);
      canvas.drawCircle(
        point,
        14,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      final text = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: const TextStyle(
            color: Colors.black,
            fontFamily: 'Nunito',
            fontSize: 16,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(canvas, point - Offset(text.width / 2, text.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _Wheel oldDelegate) => true;
}
