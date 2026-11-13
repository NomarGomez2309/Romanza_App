import 'package:romanza/design_system/romanza_icon.dart';
import 'package:flutter/material.dart';
import '../../design_system/components.dart';
import '../../design_system/romanza_theme.dart';

/// No local draft is represented as a published, shared memory.
class MemoriesScreen extends StatelessWidget {
  const MemoriesScreen({super.key, required this.onCamera});
  final VoidCallback onCamera;
  @override
  Widget build(BuildContext context) => RomanzaPage(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text('Recuerdos', style: RomanzaType.section),
        RomanzaEmptyState(
          icon: RomanzaSymbol.romanzaRecuerdos,
          title: 'Lo que quieren conservar',
          message:
              'Todavía no hay recuerdos compartidos. Puedes preparar una foto como borrador en este dispositivo.',
          action: FilledButton(
            onPressed: onCamera,
            child: const Text('Preparar una foto'),
          ),
        ),
      ],
    ),
  );
}

/// Ready for published records only; callers must obtain authorized content.
class MemoryPhotoCard extends StatelessWidget {
  const MemoryPhotoCard({
    super.key,
    required this.photo,
    required this.publishedAt,
    required this.onOpen,
  });
  final ImageProvider photo;
  final DateTime publishedAt;
  final VoidCallback onOpen;
  @override
  Widget build(BuildContext context) {
    final date = MaterialLocalizations.of(
      context,
    ).formatFullDate(publishedAt.toLocal());
    return Semantics(
      button: true,
      label: 'Recuerdo del $date',
      child: AspectRatio(
        aspectRatio: 175 / 243,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            child: InkWell(
              onTap: onOpen,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image(
                    image: photo,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        const Center(child: RomanzaIcon(RomanzaSymbol.images)),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 85),
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(12, 32, 12, 12),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xcc000000)],
                        ),
                      ),
                      child: Text(
                        date,
                        style: RomanzaType.body.copyWith(
                          fontSize: 13,
                          height: 18 / 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
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
