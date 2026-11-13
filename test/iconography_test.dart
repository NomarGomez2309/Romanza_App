import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:romanza/design_system/romanza_icon.dart';
import 'package:romanza/design_system/romanza_theme.dart';
import 'package:romanza/features/home_shell.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader(
      'Nunito',
    )..addFont(rootBundle.load('assets/fonts/Nunito.ttf'))).load();
  });
  testWidgets('all 28 original SVG assets render and remain decorative', (
    tester,
  ) async {
    expect(RomanzaSymbol.values.length, 28);
    for (final symbol in RomanzaSymbol.values) {
      expect(
        File(symbol.asset).readAsStringSync(),
        contains('viewBox="0 0 24 24"'),
      );
      await tester.pumpWidget(MaterialApp(home: RomanzaIcon(symbol)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: symbol.name);
    }
  });
  for (final width in [320.0, 390.0, 412.0]) {
    for (final scale in [1.0, 1.15, 2.0]) {
      testWidgets(
        'navigation fits $width text $scale and never resizes on selection',
        (tester) async {
          tester.view.physicalSize = Size(width, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          final semantics = tester.ensureSemantics();

          for (final palette in RomanzaPalette.values) {
            var selected = 0;
            await tester.pumpWidget(
              MaterialApp(
                theme: romanzaTheme(palette),
                home: StatefulBuilder(
                  builder: (context, setState) => Scaffold(
                    body: const Center(child: Text('Contenido')),
                    bottomNavigationBar: RomanzaNavigation(
                      selected: selected,
                      onSelect: (i) => setState(() => selected = i),
                    ),
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();
            final sizes = List.generate(
              3,
              (i) => tester.getSize(find.byKey(ValueKey('nav-pill-$i'))),
            );
            for (final size in sizes) {
              expect(size.width, greaterThanOrEqualTo(80));
              expect(size.height, greaterThanOrEqualTo(56));
            }
            expect(
              tester.getSize(find.byType(RomanzaNavigation)).height,
              lessThan(130),
            );
            expect(find.text('Contenido').hitTestable(), findsOneWidget);
            for (final label in ['Hoy', 'Planes', 'Recuerdos']) {
              final paragraph = tester.renderObject<RenderParagraph>(
                find.text(label),
              );
              expect(
                paragraph.size.height,
                lessThanOrEqualTo(18 * scale + 1),
                reason: '$width $scale $label',
              );
              await tester.tap(find.text(label));
              await tester.pumpAndSettle();
              expect(selected, ['Hoy', 'Planes', 'Recuerdos'].indexOf(label));
              expect(
                tester.getSemantics(find.bySemanticsLabel(label)),
                matchesSemantics(
                  label: label,
                  isButton: true,
                  isSelected: true,
                  hasSelectedState: true,
                  hasTapAction: true,
                  isFocusable: true,
                  hasFocusAction: true,
                ),
              );
              for (var i = 0; i < 3; i++) {
                expect(
                  tester.getSize(find.byKey(ValueKey('nav-pill-$i'))),
                  sizes[i],
                );
              }
            }
            expect(tester.takeException(), isNull);
          }
          semantics.dispose();
        },
      );
    }
  }
  test('accent and selected icon roles have readable contrast', () {
    double ratio(Color a, Color b) {
      final x = a.computeLuminance(), y = b.computeLuminance();
      return x > y ? (x + .05) / (y + .05) : (y + .05) / (x + .05);
    }

    for (final palette in RomanzaPalette.values) {
      final c = RomanzaColors.forPalette(palette);
      expect(ratio(c.accent, c.onAccent), greaterThanOrEqualTo(4.5));
      expect(ratio(c.primary, c.onPrimary), greaterThanOrEqualTo(4.5));
    }
  });
}
