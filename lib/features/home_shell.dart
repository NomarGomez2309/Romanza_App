import 'package:flutter/material.dart';
import '../design_system/romanza_navigation.dart';
export '../design_system/romanza_navigation.dart';
import '../preferences/palette_controller.dart';
import 'settings/settings_sheet.dart';
import 'camera/camera_screen.dart';
import 'memories/memories_screen.dart';
import 'today/today_screen.dart';
import 'plans/plans_screen.dart';
import 'today/important_date.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.paletteController,
    this.importantDates = const [],
  });
  final PaletteController paletteController;
  final List<ImportantDate> importantDates;
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
    extendBody: true,
    body: SafeArea(
      bottom: false,
      child: IndexedStack(
        index: _selected,
        children: [
          TodayScreen(
            importantDates: widget.importantDates,
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
          const PlansScreen(),
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
