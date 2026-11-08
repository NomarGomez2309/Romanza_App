import 'package:flutter/material.dart';

/// Initializes external services once, outside build.
class RomanzaApp extends StatefulWidget {
  const RomanzaApp({super.key, required this.initialize});

  final Future<void> Function() initialize;

  @override
  State<RomanzaApp> createState() => _RomanzaAppState();
}

class _RomanzaAppState extends State<RomanzaApp> {
  late Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = Future<void>.sync(widget.initialize);
  }

  void _retry() {
    setState(() {
      _initialization = Future<void>.sync(widget.initialize);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Romanza',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: FutureBuilder<void>(
                future: _initialization,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const CircularProgressIndicator(
                      semanticsLabel: 'Iniciando Romanza',
                    );
                  }
                  if (snapshot.hasError) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'No se pudo iniciar Romanza. '
                          'Comprueba la configuración de Firebase y vuelve a intentar.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _retry,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    );
                  }
                  return const Text('Romanza');
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
