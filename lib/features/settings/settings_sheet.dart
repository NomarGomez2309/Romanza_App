import 'dart:ui';
import 'package:flutter/material.dart';
import '../../design_system/romanza_theme.dart';
import '../../preferences/palette_controller.dart';
import '../../preferences/preferences_screen.dart';

Future<void> openSettings(
  BuildContext context,
  PaletteController controller,
) async {
  final destination = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    showDragHandle: false,
    sheetAnimationStyle: MediaQuery.disableAnimationsOf(context)
        ? AnimationStyle.noAnimation
        : const AnimationStyle(duration: Duration(milliseconds: 250)),
    builder: (context) => const SettingsSheet(),
  );
  if (!context.mounted || destination == null) return;
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => destination == 'Preferencias'
          ? PreferencesScreen(controller: controller)
          : SettingsDetail(title: destination, controller: controller),
    ),
  );
}

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});
  static const entries = <String, IconData>{
    'Cuenta': Icons.person_outline,
    'Preferencias': Icons.tune,
    'Administración de pareja': Icons.link,
    'Idioma': Icons.language,
    'Términos y condiciones': Icons.description_outlined,
    'Cerrar sesión': Icons.logout,
  };
  @override
  Widget build(BuildContext context) {
    final c = RomanzaColors.of(context);
    final opaque =
        MediaQuery.highContrastOf(context) ||
        MediaQuery.accessibleNavigationOf(context);
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: opaque ? 0 : 18,
          sigmaY: opaque ? 0 : 18,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: c.note.withValues(alpha: opaque ? 1 : .80),
            border: Border.all(color: Colors.white.withValues(alpha: .22)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(width: 52, height: 3, color: c.secondary),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 12, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Configuración',
                            style: RomanzaType.section,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Cerrar configuración',
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  for (final entry in entries.entries)
                    Padding(
                      padding: EdgeInsets.only(
                        top: entry.key == 'Cerrar sesión' ? 16 : 0,
                      ),
                      child: ListTile(
                        minTileHeight: 64,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                        ),
                        minLeadingWidth: 30,
                        leading: Icon(entry.value, size: 24, color: c.ink),
                        title: Text(
                          entry.key,
                          style: RomanzaType.body.copyWith(
                            fontSize: 17,
                            height: 24 / 17,
                          ),
                        ),
                        onTap: () => Navigator.pop(context, entry.key),
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsDetail extends StatelessWidget {
  const SettingsDetail({
    super.key,
    required this.title,
    required this.controller,
  });
  final String title;
  final PaletteController controller;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: SafeArea(
      top: false,
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (title == 'Idioma') ...[
              for (final entry in {
                true: 'Idioma del dispositivo',
                false: 'Español',
              }.entries)
                ListTile(
                  title: Text(entry.value),
                  trailing: controller.systemLanguage == entry.key
                      ? const Icon(Icons.check)
                      : null,
                  selected: controller.systemLanguage == entry.key,
                  onTap: controller.saving
                      ? null
                      : () => controller.setLanguage(entry.key),
                ),
              const Text(
                'Romanza está disponible en español. Si el dispositivo usa otro idioma, se mostrará en español.',
              ),
              if (controller.saving) const LinearProgressIndicator(),
              if (controller.error != null) Text(controller.error!),
            ] else if (title == 'Términos y condiciones') ...[
              for (final label in [
                'Condiciones de uso',
                'Política de privacidad',
              ])
                ListTile(
                  title: Text(label),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(label),
                      content: const Text(
                        'El texto definitivo todavía no está disponible.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Entendido'),
                        ),
                      ],
                    ),
                  ),
                ),
            ] else
              Text(switch (title) {
                'Cuenta' =>
                  'Todavía no hay una cuenta iniciada. El acceso y la edición del perfil estarán disponibles en una próxima entrega.',
                'Administración de pareja' =>
                  'Todavía no hay una pareja vinculada. Las invitaciones mediante enlace estarán disponibles cuando se implemente el acceso.',
                _ =>
                  'No hay una sesión iniciada que cerrar. Tus preferencias y borradores permanecen en este dispositivo.',
              }),
          ],
        ),
      ),
    ),
  );
}
