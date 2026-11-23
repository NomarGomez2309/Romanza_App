import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:romanza/design_system/romanza_navigation.dart';
import 'package:romanza/design_system/romanza_theme.dart';
import 'package:romanza/features/today/today_screen.dart';
import 'package:romanza/features/today/important_date.dart';
import 'package:romanza/features/today/upcoming_date_card.dart';
import 'package:romanza/features/today/date_home_widget_preview.dart';

final now = DateTime(2026, 11, 22, 23, 30);
ImportantDate occasion(
  int day, {
  String title = 'Nuestro aniversario',
  String id = 'a',
}) => ImportantDate(id: id, title: title, date: DateTime(2026, 11, day));
const mono = RomanzaColors(
  background: Colors.white,
  ink: Color(0xFF242424),
  secondary: Color(0xFF555555),
  primary: Color(0xFFDDDDDD),
  deep: Color(0xFFCCCCCC),
  accent: Color(0xFF555555),
  onPrimary: Color(0xFF242424),
  note: Color(0xFFF1F1F1),
  plan: Color(0xFFE4E4E4),
  memory: Color(0xFFF5F5F5),
  border: Color(0xFFC9C9C9),
);
Widget frame({
  RomanzaPalette palette = RomanzaPalette.defaultPalette,
  bool monochrome = false,
  List<ImportantDate>? dates,
  VoidCallback? onTap,
}) => MaterialApp(
  debugShowCheckedModeBanner: false,
  locale: const Locale('es'),
  supportedLocales: const [Locale('es')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: romanzaTheme(palette, custom: monochrome ? mono : null),
  home: Scaffold(
    extendBody: true,
    body: SafeArea(
      bottom: false,
      child: TodayScreen(
        onProfile: () {},
        onCamera: () {},
        onMemories: () {},
        onPlans: onTap ?? () {},
        now: now,
        importantDates: dates ?? [occasion(27)],
      ),
    ),
    bottomNavigationBar: RomanzaNavigation(selected: 0, onSelect: (_) {}),
  ),
);
Future<void> capture(
  WidgetTester tester,
  GlobalKey key,
  String name, {
  double ratio = 2,
}) async {
  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: ratio);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('docs/qa/evidence/important-date/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  setUpAll(() async {
    for (final name in ['Fredoka', 'Nunito']) {
      await (FontLoader(
        name,
      )..addFont(rootBundle.load('assets/fonts/$name.ttf'))).load();
    }
  });
  void device(WidgetTester tester, Size size, {double scale = 1}) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 32, bottom: 24);
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  test(
    'nearest excludes yesterday, sorts dates, deterministic same-day tie',
    () {
      expect(nearestImportantDate([], now), isNull);
      expect(nearestImportantDate([occasion(21)], now), isNull);
      expect(
        nearestImportantDate([
          occasion(29),
          occasion(24),
          occasion(23),
        ], now)!.date.day,
        23,
      );
      expect(
        nearestImportantDate([
          occasion(24, id: 'z'),
          occasion(24, id: 'a'),
        ], now)!.id,
        'a',
      );
    },
  );
  test(
    'calendar-day countdown handles midnight, leap year, year boundary and UTC',
    () {
      expect(occasion(23).daysFrom(now), 1);
      expect(occasion(22).countdown(now), 'Es hoy');
      expect(occasion(23).countdown(now), 'Mañana');
      expect(occasion(29).countdown(now), 'En 7 días');
      expect(
        ImportantDate(
          id: 'x',
          title: 'x',
          date: DateTime(2027, 1, 1),
        ).daysFrom(DateTime(2026, 12, 31, 23)),
        1,
      );
      expect(
        ImportantDate(
          id: 'x',
          title: 'x',
          date: DateTime(2028, 3, 1),
        ).daysFrom(DateTime(2028, 2, 28)),
        2,
      );
      final utc = DateTime.utc(2026, 11, 27, 12);
      expect(
        ImportantDate(id: 'x', title: 'x', date: utc).daysFrom(now),
        ImportantDate(id: 'x', title: 'x', date: utc.toLocal()).daysFrom(now),
      );
    },
  );
  for (final day in [21, 22, 23, 29, 30]) {
    testWidgets('seven-day window $day and tap destination', (tester) async {
      device(tester, const Size(390, 844));
      var taps = 0;
      await tester.pumpWidget(
        frame(dates: [occasion(day)], onTap: () => taps++),
      );
      await tester.pumpAndSettle();
      final visible = day >= 22 && day <= 29;
      expect(
        find.byType(ImportantDateTile),
        visible ? findsOneWidget : findsNothing,
      );
      if (visible) {
        expect(
          tester.getTopLeft(find.byType(UpcomingDateCard)).dy,
          lessThan(tester.getTopLeft(find.byType(InstantMomentsSection)).dy),
        );
        await tester.tap(find.text('Ver planes'));
        expect(taps, 1);
      }
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('empty dates do not invent anniversaries', (tester) async {
    await tester.pumpWidget(frame(dates: []));
    expect(find.byType(ImportantDateTile), findsNothing);
    expect(find.text('Un día especial'), findsNothing);
  });
  testWidgets('updated dates replace visible occasion', (tester) async {
    await tester.pumpWidget(frame(dates: [occasion(27)]));
    await tester.pumpWidget(
      frame(dates: [occasion(23, title: 'Tu cumpleaños')]),
    );
    expect(find.text('Tu cumpleaños'), findsOneWidget);
    expect(find.text('Mañana'), findsOneWidget);
    await tester.pumpWidget(frame(dates: []));
    expect(find.byType(ImportantDateTile), findsNothing);
  });
  for (final width in [320.0, 390.0, 412.0]) {
    for (final palette in RomanzaPalette.values) {
      for (final scale in [1.0, 2.0]) {
        testWidgets('layout $width ${palette.name} text $scale', (
          tester,
        ) async {
          device(tester, Size(width, width == 412 ? 924 : 844), scale: scale);
          await tester.pumpWidget(
            frame(
              palette: palette,
              dates: [
                occasion(
                  27,
                  title:
                      'Nuestro primer aniversario y un nuevo capítulo juntos',
                ),
              ],
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.ensureVisible(find.text('Ver planes'));
          expect(find.text('Ver planes').hitTestable(), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
  if (const bool.fromEnvironment('CAPTURE_DATES')) {
    for (final width in [390.0, 412.0]) {
      for (final palette in RomanzaPalette.values) {
        testWidgets('capture $width ${palette.label}', (tester) async {
          device(tester, Size(width, width == 412 ? 924 : 844));
          final key = GlobalKey();
          await tester.pumpWidget(
            RepaintBoundary(
              key: key,
              child: frame(palette: palette),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await capture(tester, key, '${palette.label}-${width.toInt()}');
        });
      }
    }
    for (final monochrome in [false, true]) {
      testWidgets('board mono $monochrome', (tester) async {
        device(tester, const Size(1254, 1230));
        final key = GlobalKey();
        await tester.pumpWidget(
          MaterialApp(
            debugShowCheckedModeBanner: false,
            home: RepaintBoundary(
              key: key,
              child: Scaffold(
                backgroundColor: const Color(0xFFECECEC),
                body: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (final palette in RomanzaPalette.values)
                        SizedBox(
                          width: 390,
                          child: Column(
                            children: [
                              Text(
                                monochrome
                                    ? 'Dashboard · ${palette.label}'
                                    : palette.label,
                                style: const TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 24,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: SizedBox(
                                  height: 844,
                                  child: MediaQuery(
                                    data: const MediaQueryData(
                                      size: Size(390, 844),
                                      padding: EdgeInsets.only(
                                        top: 24,
                                        bottom: 24,
                                      ),
                                    ),
                                    child: frame(
                                      palette: palette,
                                      monochrome: monochrome,
                                      dates: [
                                        occasion(
                                          monochrome
                                              ? switch (palette) {
                                                  RomanzaPalette
                                                      .defaultPalette =>
                                                    29,
                                                  RomanzaPalette.forest => 23,
                                                  RomanzaPalette.neo => 22,
                                                }
                                              : 27,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              const Text(
                                'Propuesta · widget del teléfono',
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: 180,
                                height: 180,
                                child: Theme(
                                  data: romanzaTheme(
                                    palette,
                                    custom: monochrome ? mono : null,
                                  ),
                                  child: Localizations(
                                    locale: const Locale('es'),
                                    delegates:
                                        GlobalMaterialLocalizations.delegates,
                                    child: DateHomeWidgetPreview(
                                      entry: occasion(27),
                                      now: now,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Margen 16 · radio 24 · bloque 84 × 84',
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await capture(
          tester,
          key,
          monochrome ? 'grid-states' : 'themes-and-home-widget',
          ratio: 1,
        );
      });
    }
  }
}
