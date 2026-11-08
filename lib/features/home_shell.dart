import 'package:flutter/material.dart';
import '../design_system/components.dart';
import '../design_system/romanza_theme.dart';
import '../preferences/palette_controller.dart';
import '../preferences/preferences_screen.dart';
import 'today/today_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.paletteController});
  final PaletteController paletteController;
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selected = 0;
  void _select(int index) => setState(() => _selected = index);
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      bottom: false,
      child: IndexedStack(
        index: _selected,
        children: [
          TodayScreen(
            onProfile: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    PreferencesScreen(controller: widget.paletteController),
              ),
            ),
            onPlans: () => _select(1),
            onMemories: () => _select(2),
          ),
          const _CollectionPage(
            title: 'Planes',
            icon: Icons.calendar_today_outlined,
            emptyTitle: 'Algo bonito por hacer',
            message:
                'Todavía no hay planes. Aquí tendrán un lugar para las cosas que quieren hacer juntos.',
          ),
          const _CollectionPage(
            title: 'Recuerdos',
            icon: Icons.photo_library_outlined,
            emptyTitle: 'Lo que quieren conservar',
            message:
                'Todavía no hay recuerdos. Aquí podrán ver lo que cada uno guarde.\n\nTus instantáneas durarán 24 horas; las que guardes aquí permanecerán. Solo tú podrás borrar las fotos y los vídeos que publiques.',
          ),
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
  final IconData icon;
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
      Icons.home_outlined,
      Icons.calendar_today_outlined,
      Icons.photo_library_outlined,
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < labels.length; i++)
                    Expanded(
                      child: Semantics(
                        selected: selected == i,
                        button: true,
                        label: labels[i],
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Align(
                            heightFactor: 1,
                            child: SizedBox(
                              width:
                                  MediaQuery.textScalerOf(context).scale(14) <=
                                      14
                                  ? 80
                                  : null,
                              child: InkWell(
                                onTap: () => onSelect(i),
                                borderRadius: BorderRadius.circular(27),
                                child: ExcludeSemantics(
                                  child: AnimatedContainer(
                                    duration:
                                        MediaQuery.disableAnimationsOf(context)
                                        ? Duration.zero
                                        : const Duration(milliseconds: 180),
                                    constraints: const BoxConstraints(
                                      minHeight: 56,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: selected == i
                                          ? c.primary
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(27),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          icons[i],
                                          size: 26,
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
