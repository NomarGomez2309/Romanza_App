import 'package:romanza/design_system/romanza_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'preferences/preferences_store.dart';
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
    this.preferencesStore,
  });
  final Future<void> Function() initialize;
  final PaletteRepository? paletteRepository;
  final PreferencesStore? preferencesStore;
  @override
  State<RomanzaApp> createState() => _RomanzaAppState();
}

class _RomanzaAppState extends State<RomanzaApp> {
  late Future<void> _initialization;
  late final PaletteController _palette;
  @override
  void initState() {
    super.initState();
    registerRomanzaIconLicenses();
    _palette = PaletteController(
      widget.paletteRepository ?? MemoryPaletteRepository(),
      store: widget.preferencesStore,
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
      theme: romanzaTheme(_palette.palette, custom: _palette.custom?.theme),
      locale: _palette.systemLanguage ? null : const Locale('es'),
      supportedLocales: const [Locale('es')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
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
                    icon: RomanzaSymbol.refreshCw,
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
