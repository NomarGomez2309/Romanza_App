import 'package:flutter/material.dart';

/// Initializes external services once, outside build.
class RomanzaApp extends StatefulWidget {
  const RomanzaApp({super.key, required this.initialize, this.homeBuilder});

  final Future<void> Function() initialize;
  final WidgetBuilder? homeBuilder;

  @override
  State<RomanzaApp> createState() => _RomanzaAppState();
}

class _RomanzaAppState extends State<RomanzaApp> {
  late Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = Future<void>.sync(
      widget.initialize,
    ).timeout(const Duration(seconds: 20));
  }

  void _retry() {
    setState(() {
      _initialization = Future<void>.sync(
        widget.initialize,
      ).timeout(const Duration(seconds: 20));
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Romanza',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: FutureBuilder<void>(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              !snapshot.hasError) {
            return widget.homeBuilder?.call(context) ??
                const Scaffold(body: Center(child: Text('Romanza')));
          }
          return Scaffold(
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: snapshot.hasError
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'No se pudo iniciar Romanza. Comprueba la configuración de Firebase y vuelve a intentar.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: _retry,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        )
                      : const CircularProgressIndicator(
                          semanticsLabel: 'Iniciando Romanza',
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
