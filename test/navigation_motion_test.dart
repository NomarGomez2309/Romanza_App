import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:romanza/design_system/romanza_navigation.dart';
import 'package:romanza/design_system/romanza_icon.dart';
import 'package:romanza/design_system/romanza_theme.dart';
import 'package:romanza/features/plans/plans_screen.dart';
import 'package:romanza/features/today/today_screen.dart';
import 'package:romanza/features/memories/memories_screen.dart';

class _Preview extends StatefulWidget {
  const _Preview({
    this.selected = 0,
    this.palette = RomanzaPalette.defaultPalette,
    this.reduced = false,
    this.rtl = false,
    this.highContrast = false,
    this.capture,
  });
  final int selected;
  final RomanzaPalette palette;
  final bool reduced, rtl, highContrast;
  final GlobalKey? capture;
  @override
  State<_Preview> createState() => _PreviewState();
}

class _PreviewState extends State<_Preview> {
  late int selected = widget.selected;
  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: romanzaTheme(widget.palette),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        disableAnimations: widget.reduced,
        highContrast: widget.highContrast,
      ),
      child: Directionality(
        textDirection: widget.rtl ? TextDirection.rtl : TextDirection.ltr,
        child: child!,
      ),
    ),
    home: RepaintBoundary(
      key: widget.capture,
      child: Scaffold(
        extendBody: true,
        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: selected,
            children: [
              TodayScreen(
                onProfile: () {},
                onPlans: () => setState(() => selected = 1),
                onMemories: () => setState(() => selected = 2),
              ),
              PlansScreen(
                now: DateTime(2026, 11, 22),
                initialPlans: [
                  PlanDraft(
                    id: 'coffee',
                    title: 'Un café sin prisas',
                    start: DateTime(2026, 11, 22, 17, 30),
                  ),
                  PlanDraft(
                    id: 'movie',
                    title: 'Peli, manta y nosotros',
                    start: DateTime(2026, 11, 22, 20),
                    minutes: 90,
                    kind: PlanKind.home,
                  ),
                ],
              ),
              MemoriesScreen(onCamera: () {}),
            ],
          ),
        ),
        bottomNavigationBar: RomanzaNavigation(
          selected: selected,
          onSelect: (value) => setState(() => selected = value),
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() async {
    for (final name in ['Fredoka', 'Nunito']) {
      await (FontLoader(
        name,
      )..addFont(rootBundle.load('assets/fonts/$name.ttf'))).load();
    }
  });
  Finder getSelector() => find.byKey(const ValueKey('nav-selector'));
  Finder tab(int index) => find.byKey(ValueKey('nav-item-$index'));
  Future<void> capture(WidgetTester tester, GlobalKey key, String name) async {
    if (!const bool.fromEnvironment('CAPTURE_NAVIGATION')) return;
    await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File(
        name.startsWith('frame-')
            ? 'build/navigation-frames/$name.png'
            : 'docs/qa/evidence/navigation/$name.png',
      );
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }

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

  testWidgets(
    'icon interior fills while pressed, cancels cleanly and stays selected',
    (tester) async {
      device(tester, 390);
      final key = GlobalKey();
      await tester.pumpWidget(_Preview(capture: key));
      await tester.pumpAndSettle();
      final icon = find.descendant(
        of: tab(1),
        matching: find.byType(RomanzaIcon),
      );
      Future<int> inkPixels() async {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final rect = tester
            .getRect(icon)
            .shift(-boundary.localToGlobal(Offset.zero));
        return (await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 1);
          final data = await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          );
          var count = 0;
          for (var y = rect.top.floor(); y < rect.bottom.ceil(); y++) {
            for (var x = rect.left.floor(); x < rect.right.ceil(); x++) {
              final index = (y * image.width + x) * 4;
              if (data!.getUint8(index) < 140 &&
                  data.getUint8(index + 1) < 140 &&
                  data.getUint8(index + 2) < 150) {
                count++;
              }
            }
          }
          image.dispose();
          return count;
        }))!;
      }

      final outline = await inkPixels();
      final gesture = await tester.startGesture(tester.getCenter(tab(1)));
      await tester.pumpAndSettle();
      expect(await inkPixels(), greaterThan(outline * 1.2));
      await gesture.cancel();
      await tester.pumpAndSettle();
      expect(await inkPixels(), closeTo(outline, 3));
      await tester.tap(tab(1));
      await tester.pumpAndSettle();
      expect(await inkPixels(), greaterThan(outline * 1.2));
      await tester.tap(tab(2));
      await tester.pumpAndSettle();
      expect(await inkPixels(), closeTo(outline, 3));
    },
  );
  if (const bool.fromEnvironment('CAPTURE_NAVIGATION')) {
    testWidgets('render palette comparison board', (tester) async {
      tester.view.physicalSize = const Size(420, 460);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: RepaintBoundary(
            key: key,
            child: Scaffold(
              backgroundColor: const Color(0xFFF8F7F4),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final palette in RomanzaPalette.values)
                    Theme(
                      data: romanzaTheme(palette),
                      child: ColoredBox(
                        color: RomanzaColors.forPalette(palette).background,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Column(
                            children: [
                              Text(
                                palette.label,
                                style: RomanzaType.body.copyWith(
                                  color: RomanzaColors.forPalette(palette).ink,
                                ),
                              ),
                              RomanzaNavigation(selected: 1, onSelect: (_) {}),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await capture(tester, key, 'palette-comparison');
    });
  }
  for (final width in [320.0, 390.0, 412.0]) {
    for (final palette in RomanzaPalette.values) {
      for (final scale in [1.0, 2.0]) {
        testWidgets('floating navigation fits $width $palette text$scale', (
          tester,
        ) async {
          device(tester, width, scale: scale);
          final key = GlobalKey();
          await tester.pumpWidget(_Preview(palette: palette, capture: key));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          for (var index = 0; index < 3; index++) {
            await tester.tap(tab(index));
            await tester.pumpAndSettle();
            final target = tester.getRect(tab(index));
            final pill = tester.getRect(getSelector());
            expect(target.width, greaterThanOrEqualTo(48));
            expect(target.height, greaterThanOrEqualTo(48));
            expect(pill.left, closeTo(target.left, .01));
            expect(pill.right, closeTo(target.right, .01));
            expect(pill.bottom, closeTo(target.bottom, .01));
            expect(tester.takeException(), isNull);
            if (width == 390 &&
                scale == 1 &&
                (palette == RomanzaPalette.defaultPalette || index == 1)) {
              await capture(tester, key, '${palette.label}-tab-$index');
            }
          }
        });
      }
    }
  }
  testWidgets(
    'selector travels continuously and redirects from its current position',
    (tester) async {
      device(tester, 390);
      final key = GlobalKey();
      await tester.pumpWidget(_Preview(capture: key));
      await tester.pumpAndSettle();
      final start = tester.getCenter(getSelector()).dx;
      await tester.tap(tab(1));
      await tester.pump();
      await capture(tester, key, 'Default-motion-start');
      await tester.pump(const Duration(milliseconds: 90));
      final middle = tester.getCenter(getSelector()).dx;
      expect(middle, greaterThan(start));
      expect(middle, lessThan(tester.getCenter(tab(1)).dx));
      await capture(tester, key, 'Default-motion-middle');
      await tester.tap(tab(2));
      await tester.pump();
      expect(tester.getCenter(getSelector()).dx, closeTo(middle, .01));
      await tester.pump(const Duration(milliseconds: 90));
      expect(tester.getCenter(getSelector()).dx, greaterThan(middle));
      await tester.pumpAndSettle();
      expect(
        tester.getCenter(getSelector()).dx,
        closeTo(tester.getCenter(tab(2)).dx, .01),
      );
      if (const bool.fromEnvironment('CAPTURE_NAVIGATION_VIDEO')) {
        var frame = 0;
        for (final target in [0, 1, 2]) {
          await tester.tap(tab(target));
          await tester.pump();
          for (var i = 0; i < 18; i++) {
            await tester.pump(const Duration(milliseconds: 30));
            await capture(
              tester,
              key,
              'frame-${(frame++).toString().padLeft(3, '0')}',
            );
          }
        }
      }
    },
  );
  testWidgets('icons compress on press and lift on activation', (tester) async {
    device(tester, 390);
    final key = GlobalKey();
    await tester.pumpWidget(_Preview(capture: key));
    await tester.pumpAndSettle();
    final icon = find.descendant(
      of: tab(1),
      matching: find.byType(RomanzaIcon),
    );
    final before = tester.getRect(icon);
    final gesture = await tester.startGesture(tester.getCenter(tab(1)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    expect(tester.getRect(icon).width, lessThan(before.width));
    await capture(tester, key, 'Default-pressed');
    await gesture.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final lifted = tester.getCenter(icon).dy;
    await tester.pumpAndSettle();
    expect(lifted, lessThan(tester.getCenter(icon).dy));
    expect(tester.getRect(icon).width, greaterThan(before.width));
  });
  testWidgets(
    'reduced motion moves the selector immediately and high contrast removes blur',
    (tester) async {
      device(tester, 390);
      await tester.pumpWidget(
        const _Preview(selected: 1, reduced: true, highContrast: true),
      );
      await tester.pumpAndSettle();
      await tester.tap(tab(2));
      await tester.pump();
      expect(
        tester.getCenter(getSelector()).dx,
        closeTo(tester.getCenter(tab(2)).dx, .01),
      );
      expect(
        find.descendant(
          of: find.byType(RomanzaNavigation),
          matching: find.byType(BackdropFilter),
        ),
        findsNothing,
      );
      final icon = find.descendant(
        of: tab(1),
        matching: find.byType(RomanzaIcon),
      );
      final width = tester.getRect(icon).width;
      final gesture = await tester.startGesture(tester.getCenter(tab(1)));
      await tester.pump(const Duration(milliseconds: 120));
      expect(tester.getRect(icon).width, closeTo(width, .01));
      await gesture.cancel();
    },
  );
  testWidgets(
    'selector respects RTL order and the final plan content stays reachable',
    (tester) async {
      device(tester, 390);
      await tester.pumpWidget(const _Preview(rtl: true));
      await tester.pumpAndSettle();
      expect(
        tester.getCenter(tab(0)).dx,
        greaterThan(tester.getCenter(tab(2)).dx),
      );
      await tester.tap(tab(1));
      await tester.pumpAndSettle();
      expect(
        tester.getCenter(getSelector()).dx,
        closeTo(tester.getCenter(tab(1)).dx, .01),
      );
      await tester.ensureVisible(
        find.text('Vista de diseño · Los borradores duran esta sesión.'),
      );
      await tester.pumpAndSettle();
      // Scroll to the end; the reserved content inset must clear the floating bar.
      await tester.drag(
        find
            .descendant(
              of: find.byType(PlansScreen),
              matching: find.byType(SingleChildScrollView),
            )
            .first,
        const Offset(0, -1000),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .getRect(
              find.text('Vista de diseño · Los borradores duran esta sesión.'),
            )
            .bottom,
        lessThan(tester.getRect(find.byType(RomanzaNavigation)).top),
      );
    },
  );
}
