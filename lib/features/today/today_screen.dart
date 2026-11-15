import '../../design_system/header_logo.dart';
import 'package:romanza/design_system/romanza_icon.dart';
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
              icon: RomanzaSymbol.romanzaNota,
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
              icon: RomanzaSymbol.calendarDays,
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
                child: const RomanzaIcon(RomanzaSymbol.images),
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
  const CoupleHeader({
    super.key,
    required this.onProfile,
    this.userImage,
    this.partnerImage,
    this.profileLabel = 'Usuario y preferencias. Sin pareja vinculada',
  });
  final VoidCallback onProfile;
  final ImageProvider? userImage, partnerImage;
  final String profileLabel;
  static const rowHeight = 72.0;
  static const avatarDiameter = 41.6;
  static const groupWidth = 76.7;
  static const unionDiameter = 15.6;
  static const heartSize = 11.05;

  @override
  Widget build(BuildContext context) {
    final c = RomanzaColors.of(context);
    return SizedBox(
      height: rowHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const HeaderLogo(),
          Tooltip(
            message: 'Usuario y preferencias',
            excludeFromSemantics: true,
            child: Semantics(
              button: true,
              label: profileLabel,
              child: InkWell(
                onTap: onProfile,
                borderRadius: BorderRadius.circular(24),
                child: ExcludeSemantics(
                  child: SizedBox(
                    key: const ValueKey('header-profile-target'),
                    width: groupWidth,
                    height: 48,
                    child: Center(
                      child: SizedBox(
                        key: const ValueKey('header-avatar-group'),
                        width: groupWidth,
                        height: avatarDiameter,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: _avatar(c.note, c.ink, userImage, 'user'),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: _avatar(
                                c.plan,
                                c.ink,
                                partnerImage,
                                'partner',
                              ),
                            ),
                            Container(
                              key: const ValueKey('header-union'),
                              width: unionDiameter,
                              height: unionDiameter,
                              decoration: BoxDecoration(
                                color: c.background,
                                shape: BoxShape.circle,
                              ),
                              child: RomanzaIcon(
                                RomanzaSymbol.heart,
                                size: heartSize,
                                color: c.ink,
                              ),
                            ),
                          ],
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
    );
  }

  Widget _avatar(Color color, Color ink, ImageProvider? image, String name) {
    final fallback = ColoredBox(
      color: color,
      child: RomanzaIcon(RomanzaSymbol.userRound, color: ink, size: 18.2),
    );
    return Container(
      key: ValueKey('header-avatar-$name'),
      width: avatarDiameter,
      height: avatarDiameter,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(1.95),
      child: ClipOval(
        child: image == null
            ? fallback
            : Image(
                image: image,
                fit: BoxFit.cover,
                excludeFromSemantics: true,
                errorBuilder: (_, _, _) => fallback,
                frameBuilder: (_, child, frame, synchronous) =>
                    synchronous || frame != null ? child : fallback,
              ),
      ),
    );
  }
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
                          color: c.accent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ExcludeSemantics(
                          child: RomanzaIcon(
                            RomanzaSymbol.plus,
                            color: c.onAccent,
                            size: 28,
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
                    icon: RomanzaSymbol.camera,
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
                    icon: RomanzaSymbol.camera,
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
  final RomanzaSymbol icon;
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
                              RomanzaIcon(icon, size: 32, color: c.secondary),
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
