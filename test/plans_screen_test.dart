import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:romanza/design_system/romanza_theme.dart';
import 'package:romanza/features/home_shell.dart';
import 'package:romanza/features/plans/plans_screen.dart';

final anchor = DateTime(2026, 11, 22);
List<PlanDraft> examples() => [
  PlanDraft(
    id: 'coffee',
    title: 'Un café sin prisas',
    start: DateTime(2026, 11, 22, 17, 30),
    kind: PlanKind.date,
  ),
  PlanDraft(
    id: 'movie',
    title: 'Peli, manta y nosotros',
    start: DateTime(2026, 11, 22, 20),
    minutes: 90,
    kind: PlanKind.home,
  ),
  PlanDraft(
    id: 'call',
    title: 'Una llamada para dos',
    start: DateTime(2026, 11, 23, 21),
    minutes: 30,
    kind: PlanKind.distance,
  ),
];
void main() {
  setUpAll(() async {
    for (final name in ['Fredoka', 'Nunito']) {
      await (FontLoader(
        name,
      )..addFont(rootBundle.load('assets/fonts/$name.ttf'))).load();
    }
  });
  Future<void> show(
    WidgetTester tester, {
    List<PlanDraft> plans = const [],
    RomanzaPalette palette = RomanzaPalette.defaultPalette,
    GlobalKey? capture,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: romanzaTheme(palette),
        home: RepaintBoundary(
          key: capture,
          child: Scaffold(
            body: SafeArea(
              child: PlansScreen(initialPlans: plans, now: anchor),
            ),
            bottomNavigationBar: RomanzaNavigation(
              selected: 1,
              onSelect: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('create, edit, complete and delete a session draft with undo', (
    tester,
  ) async {
    await show(tester);
    await tester.tap(find.byKey(const ValueKey('new-plan')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('save-plan')));
    await tester.tap(find.byKey(const ValueKey('save-plan')));
    await tester.pumpAndSettle();
    expect(find.text('Ponle un nombre al plan.'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('plan-title')),
      'Un paseo contigo',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('save-plan')));
    await tester.tap(find.byKey(const ValueKey('save-plan')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Un paseo contigo'));
    await tester.tap(find.text('Un paseo contigo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar plan'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('plan-title')),
      'Un paseo y un helado',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('save-plan')));
    await tester.tap(find.byKey(const ValueKey('save-plan')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Un paseo y un helado'));
    await tester.tap(find.text('Un paseo y un helado'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Marcar como realizado'));
    await tester.pumpAndSettle();
    expect(find.text('Realizado · Cita'), findsOneWidget);
    await tester.tap(find.text('Un paseo y un helado'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar borrador'));
    await tester.pumpAndSettle();
    expect(find.text('Un paseo y un helado'), findsNothing);
    await tester.tap(find.text('Deshacer'));
    await tester.pumpAndSettle();
    expect(find.text('Un paseo y un helado'), findsOneWidget);
  });
  testWidgets('calendar dates, day filter and month navigation agree', (
    tester,
  ) async {
    await show(tester, plans: examples());
    expect(find.text('Una llamada para dos'), findsNothing);
    await tester.tap(find.text('Calendario'));
    await tester.pumpAndSettle();
    expect(find.text('Noviembre 2026'), findsOneWidget);
    await tester.tap(find.text('Ver todo el mes'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('plan-day-31')), findsNothing);
    await tester.tap(find.byTooltip('Mes siguiente'));
    await tester.pumpAndSettle();
    expect(find.text('Diciembre 2026'), findsOneWidget);
    expect(find.byKey(const ValueKey('plan-day-31')), findsOneWidget);
    await tester.tap(find.byTooltip('Mes anterior'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('plan-day-23')));
    await tester.tap(find.byKey(const ValueKey('plan-day-23')));
    await tester.pumpAndSettle();
    expect(find.text('Una llamada para dos'), findsOneWidget);
    expect(find.text('Un café sin prisas'), findsNothing);
  });
  testWidgets('end date is explicit when a plan crosses midnight', (
    tester,
  ) async {
    await show(
      tester,
      plans: [
        PlanDraft(
          id: 'late',
          title: 'Ver las estrellas',
          start: DateTime(2026, 11, 22, 23, 30),
          minutes: 90,
        ),
      ],
    );
    await tester.ensureVisible(find.text('Fin · 23 de noviembre'));
    expect(find.text('01:00'), findsOneWidget);
  });
  Future<void> capture(WidgetTester tester, GlobalKey key, String name) async {
    if (!const bool.fromEnvironment('CAPTURE_PLANS')) return;
    await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('docs/qa/evidence/plans/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }

  for (final size in [const Size(390, 844), const Size(412, 924)]) {
    for (final palette in RomanzaPalette.values) {
      for (final scale in [1.0, 2.0]) {
        testWidgets('plans fit $size $palette text $scale', (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.view.reset);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          final key = GlobalKey();
          await show(tester, plans: examples(), palette: palette, capture: key);
          expect(tester.takeException(), isNull);
          if (scale == 1 && size.width == 390) {
            await capture(tester, key, '${palette.label}-day');
          }
          await tester.tap(find.text('Calendario'));
          await tester.pumpAndSettle();
          tester
              .state<ScrollableState>(
                find
                    .descendant(
                      of: find.byType(PlansScreen),
                      matching: find.byType(Scrollable),
                    )
                    .first,
              )
              .position
              .jumpTo(0);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          if (scale == 1 && size.width == 390) {
            await capture(tester, key, '${palette.label}-calendar');
          }
          await tester.tap(find.byKey(const ValueKey('new-plan')));
          await tester.pumpAndSettle();
          await tester.enterText(
            find.byKey(const ValueKey('plan-title')),
            'Un rato juntos',
          );
          await tester.ensureVisible(find.byKey(const ValueKey('save-plan')));
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
