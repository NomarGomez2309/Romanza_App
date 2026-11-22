import 'package:romanza/design_system/romanza_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'preferences/preferences_store.dart';
import 'design_system/components.dart';
import 'design_system/romanza_theme.dart';
import 'features/home_shell.dart';
import 'features/settings/settings_localizations.dart';
import 'preferences/palette_controller.dart';
import 'preferences/palette_repository.dart';
import 'features/auth/auth_repository.dart';
import 'features/auth/auth_gate.dart';

class RomanzaApp extends StatefulWidget {
  const RomanzaApp({
    super.key,
    required this.initialize,
    this.paletteRepository,
    this.preferencesStore,
    this.authRepository,
    this.homeBuilder,
  });
  final Future<void> Function() initialize;
  final PaletteRepository? paletteRepository;
  final PreferencesStore? preferencesStore;
  final AuthRepository? authRepository;
  // Explicit alternate entry point for the experimental secure-core flow.
  final WidgetBuilder? homeBuilder;
  @override
  State<RomanzaApp> createState() => _RomanzaAppState();
}

class _RomanzaAppState extends State<RomanzaApp> {
  late Future<void> _initialization;
  late final PaletteController _palette;
  AuthRepository? _auth;
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
    await Future.wait([
      Future<void>.sync(widget.initialize),
      _palette.load(),
    ]).timeout(const Duration(seconds: 20));
    if (widget.homeBuilder == null) {
      _auth = widget.authRepository ?? FirebaseAuthRepository();
    }
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
      localizationsDelegates: const [
        SettingsLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      home: FutureBuilder<void>(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const AuthLoadingScreen();
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
          if (widget.homeBuilder != null) {
            return widget.homeBuilder!(context);
          }
          return AuthGate(
            repository: _auth!,
            authenticated: (_) => HomeShell(paletteController: _palette),
          );
        },
      ),
    ),
  );
}
