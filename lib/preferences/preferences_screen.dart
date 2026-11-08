import 'package:flutter/material.dart';
import '../design_system/components.dart';
import '../design_system/romanza_theme.dart';
import 'palette_controller.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key, required this.controller});
  final PaletteController controller;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Usuario')),
    body: SafeArea(
      top: false,
      child: RomanzaPage(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final c = RomanzaColors.of(context);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('A tu manera', style: RomanzaType.greeting),
                const SizedBox(height: 8),
                Text(
                  'Preferencias · Paleta de colores',
                  style: RomanzaType.days.copyWith(color: c.secondary),
                ),
                const SizedBox(height: 24),
                for (final palette in RomanzaPalette.values) ...[
                  _PaletteOption(
                    palette: palette,
                    selected: controller.palette == palette,
                    onTap: controller.saving
                        ? null
                        : () => controller.select(palette),
                  ),
                  const SizedBox(height: 12),
                ],
                if (controller.saving)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: LinearProgressIndicator(
                      semanticsLabel: 'Guardando paleta',
                    ),
                  ),
                if (controller.error != null)
                  Semantics(
                    liveRegion: true,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        controller.error!,
                        style: RomanzaType.body.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ),
                Text(
                  'Se guarda en este dispositivo.',
                  style: RomanzaType.caption.copyWith(color: c.secondary),
                ),
                const SizedBox(height: 32),
                Text('Su espacio, juntos', style: RomanzaType.section),
                const SizedBox(height: 8),
                const Text(
                  'Aún no hay una cuenta ni una pareja vinculada. El acceso y las invitaciones llegarán en la siguiente etapa.',
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}

class _PaletteOption extends StatelessWidget {
  const _PaletteOption({
    required this.palette,
    required this.selected,
    required this.onTap,
  });
  final RomanzaPalette palette;
  final bool selected;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final c = RomanzaColors.forPalette(palette);
    return Semantics(
      button: true,
      selected: selected,
      label: 'Paleta ${palette.label}',
      child: Material(
        color: c.background,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          palette.label,
                          style: RomanzaType.card.copyWith(color: c.ink),
                        ),
                      ),
                      Icon(
                        selected
                            ? Icons.check_circle_outline
                            : Icons.circle_outlined,
                        color: c.ink,
                        size: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      for (final color in [
                        c.primary,
                        c.deep,
                        c.background,
                        palette == RomanzaPalette.neo ? c.ink : c.accent,
                      ])
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(color: c.secondary),
                            ),
                          ),
                        ),
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
