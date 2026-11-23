import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:romanza/design_system/romanza_theme.dart';
import 'package:romanza/design_system/romanza_navigation.dart';
import 'package:romanza/features/memories/memories_screen.dart';

final monochrome = RomanzaColors(
  background: Colors.white,
  ink: const Color(0xFF202020),
  secondary: const Color(0xFF555555),
  primary: const Color(0xFFDEDEDE),
  deep: const Color(0xFFCCCCCC),
  accent: const Color(0xFF555555),
  onPrimary: const Color(0xFF202020),
  note: const Color(0xFFF1F1F1),
  plan: const Color(0xFFE7E7E7),
  memory: const Color(0xFFF5F5F5),
  border: const Color(0xFFC9C9C9),
);
late List<MemoryRecord> fixtures;
Widget _frame({
  required List<MemoryRecord> records,
  RomanzaPalette palette = RomanzaPalette.defaultPalette,
  bool mono = false,
  MemoryGrouping grouping = MemoryGrouping.all,
  MemoryLibraryView view = MemoryLibraryView.photos,
  VoidCallback? onCamera,
  bool viewer = false,
}) => MaterialApp(
  debugShowCheckedModeBanner: false,
  locale: const Locale('es'),
  supportedLocales: const [Locale('es')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: romanzaTheme(palette, custom: mono ? monochrome : null),
  home: viewer
      ? MemoryViewer(memories: records)
      : Scaffold(
          extendBody: true,
          body: SafeArea(
            bottom: false,
            child: MemoriesScreen(
              onCamera: onCamera ?? () {},
              memories: records,
              initialGrouping: grouping,
              initialView: view,
            ),
          ),
          bottomNavigationBar: RomanzaNavigation(selected: 2, onSelect: (_) {}),
        ),
);
void main() {
  setUpAll(() async {
    for (final name in ['Fredoka', 'Nunito']) {
      await (FontLoader(
        name,
      )..addFont(rootBundle.load('assets/fonts/$name.ttf'))).load();
    }
    final photos = <ImageProvider>[];
    for (final gray in [0xFFB4B4B4, 0xFFD0D0D0, 0xFFC2C2C2, 0xFFA9A9A9]) {
      final recorder = ui.PictureRecorder();
      Canvas(recorder).drawRect(
        const Rect.fromLTWH(0, 0, 96, 128),
        Paint()..color = Color(gray),
      );
      final picture = recorder.endRecording();
      final image = await picture.toImage(96, 128);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      photos.add(MemoryImage(bytes!.buffer.asUint8List()));
      image.dispose();
      picture.dispose();
    }
    fixtures = List.generate(
      18,
      (i) => MemoryRecord(
        id: 'sample-$i',
        photo: photos[i % photos.length],
        publishedAt: i < 9
            ? DateTime(2026, 11, 22 - i, 18)
            : i < 15
            ? DateTime(2026, 10, 22 - i, 17)
            : DateTime(2025, 12, 22 - i, 16),
        caption: i == 0 ? 'Un momento para nosotros.' : '',
        collection: MemoryCollection.values[i % 3],
      ),
    );
  });
  void device(WidgetTester tester, double width, {double scale = 1}) {
    tester.view.physicalSize = Size(width, width == 412 ? 924 : 844);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = FakeViewPadding(
      top: 32,
      bottom: width == 390 ? 34 : 24,
    );
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  Future<void> show(WidgetTester tester, Widget child, {GlobalKey? key}) async {
    await tester.pumpWidget(RepaintBoundary(key: key, child: child));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  Future<void> capture(
    WidgetTester tester,
    GlobalKey key,
    String name, {
    double ratio = 2,
  }) async {
    if (!const bool.fromEnvironment('CAPTURE_MEMORIES')) return;
    await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: ratio);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('docs/qa/evidence/memories/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }

  testWidgets('empty library never turns drafts into published memories', (
    tester,
  ) async {
    var captures = 0;
    await show(tester, _frame(records: const [], onCamera: () => captures++));
    expect(find.text('Lo que quieren conservar'), findsOneWidget);
    expect(find.byType(MemoryPhotoCard), findsNothing);
    await tester.tap(find.widgetWithText(FilledButton, 'Preparar una foto'));
    expect(captures, 1);
  });
  testWidgets(
    'library sorts newest first and density changes without losing records',
    (tester) async {
      device(tester, 390);
      await show(
        tester,
        _frame(records: [fixtures[10], fixtures[1], fixtures[0]]),
      );
      final first = find.byKey(const ValueKey('memory-sample-0'));
      final next = find.byKey(const ValueKey('memory-sample-1'));
      expect(tester.getTopLeft(first).dx, lessThan(tester.getTopLeft(next).dx));
      final width = tester.getSize(first).width;
      await tester.tap(find.byTooltip('Ver en dos columnas'));
      await tester.pumpAndSettle();
      expect(tester.getSize(first).width, greaterThan(width));
      expect(find.text('3 recuerdos'), findsOneWidget);
    },
  );
  testWidgets('month and year groups open filtered libraries', (tester) async {
    device(tester, 390);
    await show(tester, _frame(records: fixtures));
    await tester.tap(find.text('Meses'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Noviembre 2026'));
    await tester.pumpAndSettle();
    expect(find.text('9 recuerdos'), findsOneWidget);
    expect(find.byKey(const ValueKey('memory-sample-10')), findsNothing);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Años'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2026'));
    await tester.pumpAndSettle();
    expect(find.text('15 recuerdos'), findsOneWidget);
  });
  testWidgets('collections keep categories separate', (tester) async {
    device(tester, 390);
    await show(
      tester,
      _frame(records: fixtures, view: MemoryLibraryView.collections),
    );
    await tester.ensureVisible(find.text('Nosotros'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nosotros'));
    await tester.pumpAndSettle();
    expect(find.text('6 recuerdos'), findsOneWidget);
    expect(find.byKey(const ValueKey('memory-sample-1')), findsNothing);
  });
  testWidgets(
    'viewer supports swipe, thumbnails, boundaries and returning to library',
    (tester) async {
      device(tester, 390);
      await show(tester, _frame(records: fixtures.take(4).toList()));
      await tester.tap(find.byKey(const ValueKey('memory-sample-0')));
      await tester.pumpAndSettle();
      expect(find.text('1 de 4'), findsOneWidget);
      await tester.drag(
        find.byKey(const ValueKey('memory-pages')),
        const Offset(-320, 0),
      );
      await tester.pumpAndSettle();
      expect(find.text('2 de 4'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('memory-thumb-3')));
      await tester.pumpAndSettle();
      expect(find.text('4 de 4'), findsOneWidget);
      expect(
        tester
            .widget<IconButton>(
              find.byWidgetPredicate(
                (widget) =>
                    widget is IconButton &&
                    widget.tooltip == 'Recuerdo siguiente',
              ),
            )
            .onPressed,
        isNull,
      );
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('4 recuerdos'), findsOneWidget);
    },
  );
  testWidgets('decode failure has a visible accessible fallback', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await show(
      tester,
      _frame(
        records: [
          MemoryRecord(
            id: 'bad',
            photo: MemoryImage(Uint8List.fromList([0, 1, 2])),
            publishedAt: DateTime(2026, 11, 22),
          ),
        ],
      ),
    );
    expect(find.bySemanticsLabel(RegExp('Foto no disponible')), findsWidgets);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });
  for (final width in [390.0, 412.0]) {
    for (final palette in RomanzaPalette.values) {
      for (final scale in [1.0, 2.0]) {
        testWidgets('memory layouts fit $width $palette text$scale', (
          tester,
        ) async {
          device(tester, width, scale: scale);
          for (final grouping in MemoryGrouping.values) {
            final key = GlobalKey();
            await show(
              tester,
              _frame(records: fixtures, palette: palette, grouping: grouping),
              key: key,
            );
            if (scale == 1 && width == 390 && grouping == MemoryGrouping.all) {
              await capture(tester, key, '${palette.label}-photos');
            }
          }
          final key = GlobalKey();
          await show(
            tester,
            _frame(
              records: fixtures,
              palette: palette,
              view: MemoryLibraryView.collections,
            ),
            key: key,
          );
          if (scale == 1 &&
              width == 390 &&
              palette == RomanzaPalette.defaultPalette) {
            await capture(tester, key, 'Default-collections');
          }
          await show(
            tester,
            _frame(records: fixtures, palette: palette, viewer: true),
          );
        });
      }
    }
  }
  if (const bool.fromEnvironment('CAPTURE_MEMORIES')) {
    for (final width in [390.0, 412.0]) {
      testWidgets('monochrome production references $width', (tester) async {
        device(tester, width);
        for (final entry in [
          'photos',
          'months',
          'years',
          'collections',
          'viewer',
        ]) {
          final key = GlobalKey();
          await show(
            tester,
            _frame(
              records: fixtures,
              mono: true,
              grouping: entry == 'months'
                  ? MemoryGrouping.months
                  : entry == 'years'
                  ? MemoryGrouping.years
                  : MemoryGrouping.all,
              view: entry == 'collections'
                  ? MemoryLibraryView.collections
                  : MemoryLibraryView.photos,
              viewer: entry == 'viewer',
            ),
            key: key,
          );
          await capture(tester, key, 'grid-$entry-${width.toInt()}');
        }
      });
    }
    testWidgets('production grid board', (tester) async {
      tester.view.physicalSize = const Size(2070, 960);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final key = GlobalKey();
      await show(
        tester,
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: RepaintBoundary(
            key: key,
            child: Scaffold(
              backgroundColor: const Color(0xFFECECEC),
              body: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final entry in [
                      'Biblioteca',
                      'Por meses',
                      'Por años',
                      'Colecciones',
                      'Visor',
                    ])
                      SizedBox(
                        width: 390,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              entry,
                              style: const TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '390 × 844 · margen 16 · radios 16 / 24',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: SizedBox(
                                height: 844,
                                child: MediaQuery(
                                  data: const MediaQueryData(
                                    size: Size(390, 844),
                                    padding: EdgeInsets.only(
                                      top: 24,
                                      bottom: 20,
                                    ),
                                  ),
                                  child: _frame(
                                    records: fixtures,
                                    mono: true,
                                    grouping: entry == 'Por meses'
                                        ? MemoryGrouping.months
                                        : entry == 'Por años'
                                        ? MemoryGrouping.years
                                        : MemoryGrouping.all,
                                    view: entry == 'Colecciones'
                                        ? MemoryLibraryView.collections
                                        : MemoryLibraryView.photos,
                                    viewer: entry == 'Visor',
                                  ),
                                ),
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
      await capture(tester, key, 'production-grid-board', ratio: 1);
    });
  }
}
