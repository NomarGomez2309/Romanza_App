import 'package:flutter/material.dart';
import 'design_system/components.dart';
import 'design_system/romanza_theme.dart';
import 'features/home_shell.dart';
import 'preferences/palette_controller.dart';
import 'preferences/palette_repository.dart';

class RomanzaApp extends StatefulWidget {
  const RomanzaApp({
    super.key,
    required this.initialize,
    this.paletteRepository,
  });
  final Future<void> Function() initialize;
  final PaletteRepository? paletteRepository;
  @override
  State<RomanzaApp> createState() => _RomanzaAppState();
}

class _RomanzaAppState extends State<RomanzaApp> {
  late Future<void> _initialization;
  late final PaletteController _palette;
  @override
  void initState() {
    super.initState();
    _palette = PaletteController(
      widget.paletteRepository ?? MemoryPaletteRepository(),
    );
    _initialization = _start();
  }

  Future<void> _start() async {
    await Future.wait([Future<void>.sync(widget.initialize), _palette.load()]);
  }

  void _retry() => setState(() {
    _initialization = _start();
  });
  @override
  void dispose() {
    _palette.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _palette,
    builder: (context, _) => MaterialApp(
      title: 'Romanza',
      debugShowCheckedModeBanner: false,
      theme: romanzaTheme(_palette.palette),
      home: FutureBuilder<void>(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: SafeArea(
                child: Center(
                  child: CircularProgressIndicator(
                    semanticsLabel: 'Iniciando Romanza',
                  ),
                ),
              ),
            );
          }
          if (snapshot.hasError) {
            return Scaffold(
              body: SafeArea(
                child: RomanzaPage(
                  child: RomanzaEmptyState(
                    icon: Icons.cloud_off_outlined,
                    title: 'No pudimos empezar',
                    message:
                        'No se pudo iniciar Romanza. Vuelve a intentarlo en un momento.',
                    action: FilledButton(
                      onPressed: _retry,
                      child: const Text('Reintentar'),
                    ),
                  ),
                ),
              ),
            );
          }
          return HomeShell(paletteController: _palette);
        },
      ),
    ),
  );
}
