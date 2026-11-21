import 'package:flutter/material.dart';
import '../design_system/components.dart';
import '../design_system/romanza_icon.dart';
import '../design_system/romanza_theme.dart';
import '../features/settings/settings_localizations.dart';
import 'palette_controller.dart';
import 'custom_palette.dart';
import 'custom_palette_screen.dart';
import 'custom_duo_screen.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key, required this.controller});
  final PaletteController controller;
  static const presetColors = [
    [
      Color(0xff9fa0ff),
      Color(0xffd5e8e6),
      Color(0xfffff3e3),
      Color(0xffff7171),
    ],
    [
      Color(0xfff3f6f4),
      Color(0xff7d8d39),
      Color(0xff5b6e2c),
      Color(0xffff5a22),
    ],
    [
      Color(0xff08cb00),
      Color(0xff253900),
      Color(0xff000000),
      Color(0xffeeeeee),
    ],
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(SettingsLocalizations.of(context).themes),
      actions: [
        Tooltip(
          message: 'Custom Duo',
          child: TextButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const CustomDuoScreen()),
            ),
            icon: const RomanzaIcon(RomanzaSymbol.link, size: 20),
            label: const Text('Duo'),
          ),
        ),
        const SizedBox(width: 8),
      ],
    ),
    body: SafeArea(
      top: false,
      child: RomanzaPage(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Text(
                  'Paleta de color',
                  style: RomanzaType.heading(22, 28, 500),
                ),
                const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final side = (constraints.maxWidth - 12) / 2;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (var i = 0; i < RomanzaPalette.values.length; i++)
                          SizedBox(
                            width: side,
                            child: ThemePaletteCard(
                              label: RomanzaPalette.values[i].label,
                              colors: presetColors[i],
                              selected:
                                  controller.custom == null &&
                                  controller.palette ==
                                      RomanzaPalette.values[i],
                              onTap: controller.saving
                                  ? null
                                  : () => controller.select(
                                      RomanzaPalette.values[i],
                                    ),
                            ),
                          ),
                        SizedBox(
                          width: side,
                          child: ThemePaletteCard(
                            label: 'Custom',
                            onTap: controller.saving
                                ? null
                                : () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => CustomPaletteScreen(
                                        controller: controller,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        for (var i = 0; i < controller.bank.length; i++)
                          SizedBox(
                            width: side,
                            child: ThemePaletteCard(
                              label: 'Paleta ${i + 1}',
                              colors: controller.bank[i].colors,
                              selected:
                                  controller.activeCustomId ==
                                  controller.bank[i].id,
                              onTap: controller.saving
                                  ? null
                                  : () => controller.saveCustom(
                                      controller.bank[i],
                                    ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                if (controller.saving)
                  const LinearProgressIndicator(
                    semanticsLabel: 'Guardando tema',
                  ),
                if (controller.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Semantics(
                      liveRegion: true,
                      child: Text(controller.error!),
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    ),
  );
}

/// Four exact brand swatches; only labels grow with the system text size.
class ThemePaletteCard extends StatelessWidget {
  const ThemePaletteCard({
    super.key,
    required this.label,
    this.colors,
    this.selected = false,
    this.onTap,
  });
  final String label;
  final List<Color>? colors;
  final bool selected;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final c = RomanzaColors.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      onTap: onTap,
      child: ExcludeSemantics(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final swatchHeight = constraints.maxWidth - 64;
            return Material(
              color: c.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: selected ? c.primary : c.border,
                  width: selected ? 2 : 1,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: swatchHeight,
                        child: colors == null
                            ? RomanzaIcon(
                                RomanzaSymbol.paintbrush,
                                size: 48,
                                color: c.primary,
                              )
                            : Column(
                                children: [
                                  for (var i = 0; i < 4; i++) ...[
                                    if (i > 0) const SizedBox(height: 5),
                                    Expanded(
                                      flex: [16, 16, 30, 38][i],
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: colors![i],
                                          border: Border.all(
                                            color: c.border.withValues(
                                              alpha: .55,
                                            ),
                                            width: .5,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              label,
                              style: RomanzaType.body.copyWith(
                                fontSize: 17,
                                height: 24 / 17,
                              ),
                            ),
                          ),
                          if (selected) ...[
                            const SizedBox(width: 6),
                            RomanzaIcon(
                              RomanzaSymbol.check,
                              size: 22,
                              color: c.ink,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
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
  Widget build(BuildContext context) {
    final c = RomanzaColors.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      onTap: onTap,
      child: ExcludeSemantics(
        child: Material(
          color: c.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: selected ? c.primary : c.border,
              width: selected ? 2 : 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final color in palette.colors)
                    Container(
                      height: 12,
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(label.split(' ').last, style: RomanzaType.caption),
                      if (selected) ...[
                        const SizedBox(width: 4),
                        RomanzaIcon(
                          RomanzaSymbol.check,
                          size: 18,
                          color: c.ink,
                        ),
                      ],
                    ],
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
