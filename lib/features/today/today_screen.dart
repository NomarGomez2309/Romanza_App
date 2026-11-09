import 'package:flutter/material.dart';
import '../../design_system/components.dart';
import '../../design_system/romanza_theme.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({
    super.key,
    required this.onProfile,
    required this.onPlans,
    required this.onMemories,
    this.onCamera,
  });
  final VoidCallback onProfile, onPlans, onMemories;
  final VoidCallback? onCamera;

  @override
  Widget build(BuildContext context) {
    final c = RomanzaColors.of(context);
    return RomanzaPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CoupleHeader(onProfile: onProfile),
          const SizedBox(height: 8),
          Semantics(
            header: true,
            child: Text('Hoy, contigo', style: RomanzaType.greeting),
          ),
          Text(
            'Aún no hay una pareja vinculada',
            style: RomanzaType.days.copyWith(color: c.secondary),
          ),
          const SizedBox(height: 16),
          InstantMomentsSection(onCamera: onCamera),
          const SizedBox(height: 14),
          RomanzaPreviewCard(
            title: 'Te guardé esto',
            subtitle: 'Un espacio para tus palabras',
            leading: const RomanzaBadge(
              icon: Icons.mail_outline_rounded,
              shape: BadgeShape.clover,
            ),
            color: c.note,
            onTap: () => showRomanzaInfo(
              context,
              title: 'Una nota para ustedes',
              message:
                  'Todavía no hay notas. Podrás compartirlas cuando esté disponible el acceso y la vinculación de pareja.',
            ),
          ),
          const SizedBox(height: 8),
          RomanzaPreviewCard(
            title: 'Nuestro próximo plan',
            subtitle: 'Algo bonito por hacer',
            leading: const RomanzaBadge(
              icon: Icons.calendar_today_outlined,
              shape: BadgeShape.hexagon,
            ),
            color: c.plan,
            onTap: onPlans,
          ),
          const SizedBox(height: 10),
          RomanzaPreviewCard(
            title: 'Un recuerdo nuestro',
            subtitle: 'Aquí empieza su colección',
            leading: ExcludeSemantics(
              child: Container(
                width: 80,
                height: 52,
                decoration: BoxDecoration(
                  color: c.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.photo_outlined),
              ),
            ),
            color: c.memory,
            memory: true,
            onTap: onMemories,
          ),
        ],
      ),
    );
  }
}

class CoupleHeader extends StatelessWidget {
  const CoupleHeader({super.key, required this.onProfile});
  final VoidCallback onProfile;
  @override
  Widget build(BuildContext context) {
    final c = RomanzaColors.of(context);
    final large = MediaQuery.textScalerOf(context).scale(30) > 42;
    final avatars = Tooltip(
      message: 'Usuario y preferencias',
      child: Semantics(
        button: true,
        label: 'Usuario y preferencias. Sin pareja vinculada',
        child: InkWell(
          onTap: onProfile,
          borderRadius: BorderRadius.circular(36),
          child: ExcludeSemantics(
            child: SizedBox(
              width: 118,
              height: 72,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 0,
                    child: _avatar(c.note, Icons.person_outline_rounded, c.ink),
                  ),
                  Positioned(
                    right: 0,
                    child: _avatar(
                      c.plan,
                      Icons.person_add_alt_outlined,
                      c.ink,
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: c.background,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite_border_rounded,
                      size: 17,
                      color: c.ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    final brand = Text('romanza', style: RomanzaType.brand);
    return large
        ? Wrap(
            spacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [brand, avatars],
          )
        : Row(
            children: [
              Expanded(child: brand),
              avatars,
            ],
          );
  }

  Widget _avatar(Color color, IconData icon, Color ink) => Container(
    width: 64,
    height: 64,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 3),
    ),
    child: Icon(icon, color: ink, size: 28),
  );
}

class InstantMomentsSection extends StatelessWidget {
  const InstantMomentsSection({super.key, this.onCamera});
  final VoidCallback? onCamera;
  @override
  Widget build(BuildContext context) {
    final c = RomanzaColors.of(context);
    void explain() => showRomanzaInfo(
      context,
      title: 'Un momento de tu día',
      message:
          'Las instantáneas durarán 24 horas. Podrás guardar las tuyas en Recuerdos para conservarlas.\n\nLa subida de fotos y vídeos estará disponible después de vincular las cuentas.',
    );
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text('Instantáneas', style: RomanzaType.section),
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: 'Añadir instantánea',
              child: Semantics(
                button: true,
                label: 'Añadir instantánea',
                child: InkWell(
                  onTap: onCamera ?? explain,
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 52,
                    height: 48,
                    child: Center(
                      child: Ink(
                        width: 52,
                        height: 44,
                        decoration: BoxDecoration(
                          color: c.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ExcludeSemantics(
                          child: Icon(
                            Icons.add_rounded,
                            color: c.onPrimary,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = (constraints.maxWidth - RomanzaSpace.gap) / 2;
            final base = width / RomanzaSpace.photoRatio;
            final scaled = MediaQuery.textScalerOf(context).scale(14) / 14;
            final height = base + (scaled - 1).clamp(0, 3) * 100;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: MomentCard(
                    title: 'Tu momento',
                    subtitle: 'Comparte algo de hoy',
                    height: height,
                    color: c.note,
                    icon: Icons.add_a_photo_outlined,
                    onTap: onCamera ?? explain,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MomentCard(
                    title: 'Su momento',
                    subtitle: 'Un espacio para su día',
                    height: height,
                    color: c.plan,
                    icon: Icons.wb_sunny_outlined,
                    onTap: () => showRomanzaInfo(
                      context,
                      title: 'Su momento',
                      message:
                          'Aquí verás la instantánea de tu pareja cuando vinculen sus cuentas. Todavía no hay contenido compartido.',
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class MomentCard extends StatelessWidget {
  const MomentCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.height,
    required this.color,
    required this.icon,
    required this.onTap,
  });
  final String title, subtitle;
  final double height;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final c = RomanzaColors.of(context);
    return Semantics(
      button: true,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: height,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Center(
                      child: ExcludeSemantics(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome_outlined,
                                size: 18,
                                color: c.secondary,
                              ),
                              const SizedBox(height: 10),
                              Icon(icon, size: 32, color: c.secondary),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(title, style: RomanzaType.card),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: RomanzaType.time.copyWith(color: c.secondary),
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
