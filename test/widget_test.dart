import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:romanza/app.dart';

void main() {
  testWidgets('waits for initialization before showing the empty app', (
    tester,
  ) async {
    final initialization = Completer<void>();
    var calls = 0;
    await tester.pumpWidget(
      RomanzaApp(
        initialize: () {
          calls++;
          return initialization.future;
        },
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Romanza'), findsNothing);
    await tester.pump();
    expect(calls, 1);
    initialization.complete();
    await tester.pumpAndSettle();
    expect(find.text('Romanza'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('shows initialization failure and allows a successful retry', (
    tester,
  ) async {
    var attempts = 0;
    await tester.pumpWidget(
      RomanzaApp(
        initialize: () async {
          if (++attempts == 1) throw StateError('Initialization failed');
        },
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Reintentar'), findsOneWidget);
    expect(find.text('Romanza'), findsNothing);
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(attempts, 2);
    expect(find.text('Romanza'), findsOneWidget);
  });
  testWidgets('constructs the session screen only after initialization', (
    tester,
  ) async {
    final initialized = Completer<void>();
    var builds = 0;
    await tester.pumpWidget(
      RomanzaApp(
        initialize: () => initialized.future,
        homeBuilder: (_) {
          builds++;
          return const Scaffold(body: Text('Session ready'));
        },
      ),
    );
    expect(builds, 0);
    initialized.complete();
    await tester.pumpAndSettle();
    expect(find.text('Session ready'), findsOneWidget);
  });

  testWidgets('a stalled initialization times out and can be retried', (
    tester,
  ) async {
    final stalled = Completer<void>();
    var attempts = 0;
    await tester.pumpWidget(
      RomanzaApp(
        initialize: () =>
            ++attempts == 1 ? stalled.future : Future<void>.value(),
      ),
    );
    await tester.pump(const Duration(seconds: 21));
    await tester.pump();
    expect(find.text('Reintentar'), findsOneWidget);
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(attempts, 2);
    expect(find.text('Romanza'), findsOneWidget);
  });
}
