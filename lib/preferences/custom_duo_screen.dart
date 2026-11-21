import 'package:flutter/material.dart';
import '../design_system/components.dart';
import '../design_system/romanza_icon.dart';
import '../design_system/romanza_theme.dart';
import 'custom_palette.dart';

/// Only a local color draft is available until authenticated couple syncing exists.
class CustomDuoScreen extends StatefulWidget {
  const CustomDuoScreen({super.key});
  @override
  State<CustomDuoScreen> createState() => _CustomDuoScreenState();
}

class _CustomDuoScreenState extends State<CustomDuoScreen> {
  Color? draft;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('Custom Duo', style: RomanzaType.heading(26, 32, 500)),
    ),
    body: SafeArea(
      top: false,
      child: RomanzaPage(
        child: Column(
          children: [
            const SizedBox(height: 16),
            CustomDuoColorSelection(
              myDraft: draft,
              partnerDraft: null,
              myConfirmed: false,
              partnerConfirmed: false,
              onSelect: (color) => setState(() => draft = color),
            ),
            const SizedBox(height: 16),
            Text(
              'Custom Duo requiere una cuenta y una pareja vinculada. Por ahora puedes explorar los colores.',
              style: RomanzaType.body.copyWith(
                color: RomanzaColors.of(context).secondary,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
  );
}

/// Controlled view based on the handoff. The parent must supply server-confirmed
/// contributions; this widget never impersonates or confirms for a partner.
class CustomDuoColorSelection extends StatelessWidget {
  const CustomDuoColorSelection({
    super.key,
    required this.myDraft,
    required this.partnerDraft,
    required this.myConfirmed,
    required this.partnerConfirmed,
    required this.onSelect,
    this.onConfirm,
    this.onGenerate,
  });
  final Color? myDraft, partnerDraft;
  final bool myConfirmed, partnerConfirmed;
  final ValueChanged<Color> onSelect;
  final VoidCallback? onConfirm, onGenerate;
  static const colors = [
    Color(0xff9fa0ff),
    Color(0xffff7171),
    Color(0xffd5e8e6),
    Color(0xffe9b4c7),
    Color(0xff9fc9ea),
    Color(0xfff1d787),
    Color(0xffedb894),
    Color(0xffa8bc91),
    Color(0xffb8a1cf),
    Color(0xffc97d65),
  ];
  static const names = [
    'Lavanda',
    'Coral',
    'Menta',
    'Rosa',
    'Azul',
    'Amarillo',
    'Melocotón',
    'Salvia',
    'Malva',
    'Terracota',
  ];
  @override
  Widget build(BuildContext context) {
    final c = RomanzaColors.of(context);
    final heading =
        TextPainter(
          text: TextSpan(
            text: 'Tu pareja',
            style: RomanzaType.heading(20, 26, 500),
          ),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(
          maxWidth:
              (MediaQuery.sizeOf(
                    context,
                  ).width.clamp(0, RomanzaSpace.maxWidth) -
                  44) /
              2,
        );
    final headingHeight = heading.height;
    heading.dispose();
    Widget tile(String name, Color? color, bool confirmed, bool own) {
      final state = confirmed
          ? 'Confirmado'
          : color == null
          ? 'Sin elegir'
          : 'Por confirmar';
      return Expanded(
        child: Column(
          children: [
            SizedBox(
              height: headingHeight,
              child: Center(
                child: Text(name, style: RomanzaType.heading(20, 26, 500)),
              ),
            ),
            const SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 1,
              child: Semantics(
                label: own ? 'Confirmar mi color' : 'Color de tu pareja',
                value: state,
                button: own,
                enabled: own ? color != null && onConfirm != null : null,
                onTap: own && color != null ? onConfirm : null,
                child: ExcludeSemantics(
                  child: Material(
                    color: color ?? c.note,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: confirmed ? c.primary : c.border,
                        width: confirmed ? 2 : 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: own && color != null ? onConfirm : null,
                      child: Stack(
                        children: [
                          if (color == null)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(
                                  'Sin elegir',
                                  textAlign: TextAlign.center,
                                  style: RomanzaType.body.copyWith(
                                    color: c.ink,
                                  ),
                                ),
                              ),
                            ),
                          if (confirmed)
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const RomanzaIcon(
                                  RomanzaSymbol.check,
                                  size: 20,
                                  color: Color(0xff302c46),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (color != null)
              Text(state, textAlign: TextAlign.center, style: RomanzaType.body)
            else
              SizedBox(height: MediaQuery.textScalerOf(context).scale(20)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Un color de cada uno.',
          style: RomanzaType.body.copyWith(fontSize: 16, height: 24 / 16),
        ),
        const SizedBox(height: 28),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            tile('Tú', myDraft, myConfirmed, true),
            const SizedBox(width: 12),
            tile('Tu pareja', partnerDraft, partnerConfirmed, false),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Elige el color que más va contigo.',
          style: RomanzaType.body,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) => Wrap(
            runSpacing: 12,
            children: [
              for (var i = 0; i < colors.length; i++)
                SizedBox(
                  width: constraints.maxWidth / 5,
                  height: 48,
                  child: Center(
                    child: Semantics(
                      button: true,
                      selected: myDraft == colors[i],
                      label: names[i],
                      onTap: () => onSelect(colors[i]),
                      child: ExcludeSemantics(
                        child: InkResponse(
                          onTap: () => onSelect(colors[i]),
                          radius: 24,
                          child: Container(
                            width: 48,
                            height: 48,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: myDraft == colors[i]
                                  ? Border.all(color: c.ink, width: 2)
                                  : null,
                            ),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: colors[i],
                                shape: BoxShape.circle,
                              ),
                              child: myDraft == colors[i]
                                  ? RomanzaIcon(
                                      RomanzaSymbol.check,
                                      size: 20,
                                      color: CustomPalette.readable(colors[i]),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: FilledButton.icon(
            onPressed:
                myConfirmed &&
                    partnerConfirmed &&
                    myDraft != null &&
                    partnerDraft != null
                ? onGenerate
                : null,
            icon: const RomanzaIcon(RomanzaSymbol.wandSparkles, size: 20),
            label: const Text('Generar combinaciones'),
          ),
        ),
        const SizedBox(height: 12),
        Semantics(
          liveRegion: true,
          child: Text(
            myConfirmed && partnerConfirmed
                ? 'Listo para crear sus combinaciones.'
                : 'Disponible cuando ambos confirmen.',
            textAlign: TextAlign.center,
            style: RomanzaType.body,
          ),
        ),
      ],
    );
  }
}
