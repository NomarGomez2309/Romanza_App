import 'package:romanza/design_system/romanza_icon.dart';
import 'package:flutter/material.dart';
import '../design_system/components.dart';
import '../design_system/romanza_theme.dart';
import '../preferences/palette_controller.dart';
import 'settings/settings_sheet.dart';
import 'camera/camera_screen.dart';
import 'memories/memories_screen.dart';
import 'today/today_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.paletteController});
  final PaletteController paletteController;
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final _profileFocus = FocusNode(debugLabel: 'Inicio: cuenta');
  @override
  void dispose() {
    _profileFocus.dispose();
    super.dispose();
  }

  int _selected = 0;
  void _select(int index) => setState(() => _selected = index);
  void _camera() => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const InstantCameraScreen()));
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      bottom: false,
      child: IndexedStack(
        index: _selected,
        children: [
          TodayScreen(
            profileFocus: _profileFocus,
            onProfile: () => openSettings(
              context,
              widget.paletteController,
              returnFocus: _profileFocus,
            ),
            onCamera: _camera,
            onPlans: () => _select(1),
            onMemories: () => _select(2),
          ),
          const _CollectionPage(
            title: 'Planes',
            icon: RomanzaSymbol.calendarDays,
            emptyTitle: 'Algo bonito por hacer',
            message:
                'Todavía no hay planes. Aquí tendrán un lugar para las cosas que quieren hacer juntos.',
          ),
          MemoriesScreen(onCamera: _camera),
        ],
      ),
    ),
    bottomNavigationBar: RomanzaNavigation(
      selected: _selected,
      onSelect: _select,
    ),
  );
}

class _CollectionPage extends StatelessWidget {
  const _CollectionPage({
    required this.title,
    required this.icon,
    required this.emptyTitle,
    required this.message,
  });
  final String title, emptyTitle, message;
  final RomanzaSymbol icon;
  @override
  Widget build(BuildContext context) => RomanzaPage(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Semantics(
          header: true,
          child: Text(title, style: RomanzaType.greeting),
        ),
        RomanzaEmptyState(icon: icon, title: emptyTitle, message: message),
      ],
    ),
  );
}

class RomanzaNavigation extends StatelessWidget {
  const RomanzaNavigation({
    super.key,
    required this.selected,
    required this.onSelect,
  });
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final c = RomanzaColors.of(context);
    const labels = ['Hoy', 'Planes', 'Recuerdos'];
    const icons = [
      RomanzaSymbol.romanzaHoy,
      RomanzaSymbol.calendarDays,
      RomanzaSymbol.romanzaRecuerdos,
    ];
    return Material(
      color: c.background,
      child: SafeArea(
        top: false,
        child: Align(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: RomanzaSpace.maxWidth,
              minHeight: 72,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal:
                    MediaQuery.sizeOf(context).width < 360 &&
                        MediaQuery.textScalerOf(context).scale(14) > 21
                    ? 8
                    : 16,
                vertical: 8,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final textWidths = labels.map((label) {
                    final painter = TextPainter(
                      text: TextSpan(
                        text: label,
                        style: DefaultTextStyle.of(
                          context,
                        ).style.merge(RomanzaType.navigation),
                      ),
                      textDirection: Directionality.of(context),
                      textScaler: MediaQuery.textScalerOf(context),
                    )..layout();
                    final width = painter.width.ceilToDouble();
                    painter.dispose();
                    return width;
                  }).toList();
                  final available = constraints.maxWidth;
                  final equal = available / 3;
                  var padding = 16.0;
                  List<double> needed() => textWidths
                      .map((w) => (w + padding).clamp(80.0, available))
                      .toList();
                  var widths = needed();
                  if (widths.fold<double>(0, (a, b) => a + b) > available) {
                    padding = 0;
                    widths = needed();
                  }
                  final total = widths.fold<double>(0, (a, b) => a + b);
                  final slots = widths.every((w) => w <= equal)
                      ? List<double>.filled(3, equal)
                      : total <= available
                      ? widths.map((w) => w + (available - total) / 3).toList()
                      : List<double>.filled(3, equal);
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < 3; i++)
                        SizedBox(
                          width: slots[i],
                          child: Center(
                            heightFactor: 1,
                            child: Semantics(
                              selected: selected == i,
                              button: true,
                              label: labels[i],
                              child: InkWell(
                                onTap: () => onSelect(i),
                                borderRadius: BorderRadius.circular(28),
                                child: ExcludeSemantics(
                                  child: AnimatedContainer(
                                    key: ValueKey('nav-pill-$i'),
                                    duration:
                                        MediaQuery.disableAnimationsOf(context)
                                        ? Duration.zero
                                        : const Duration(milliseconds: 160),
                                    width: widths[i].clamp(0.0, slots[i]),
                                    constraints: const BoxConstraints(
                                      minHeight: 56,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: padding / 2,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: selected == i
                                          ? c.primary
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        RomanzaIcon(
                                          icons[i],
                                          size: 24,
                                          color: selected == i
                                              ? c.onPrimary
                                              : c.ink,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          labels[i],
                                          textAlign: TextAlign.center,
                                          style: RomanzaType.navigation
                                              .copyWith(
                                                color: selected == i
                                                    ? c.onPrimary
                                                    : c.ink,
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
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
