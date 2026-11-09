import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:romanza/app.dart';
import 'package:romanza/design_system/romanza_theme.dart';
import 'package:romanza/features/home_shell.dart';
import 'package:romanza/preferences/palette_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final font in ['Fredoka', 'Nunito']) {
      await (FontLoader(
        font,
      )..addFont(rootBundle.load('assets/fonts/$font.ttf'))).load();
    }
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  for (final size in [
    const Size(320, 640),
    const Size(412, 924),
    const Size(844, 390),
    const Size(1024, 768),
  ]) {
    for (final scale in [1.0, 1.15, 2.0]) {
      testWidgets('audit ${size.width}x${size.height} scale $scale', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(RomanzaApp(initialize: () async {}));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final nav = find.byType(RomanzaNavigation);
        final pills = find.descendant(
          of: nav,
          matching: find.byType(AnimatedContainer),
        );
        final targets = find.descendant(
          of: nav,
          matching: find.byType(InkWell),
        );
        debugPrint(
          'TAP TARGETS ${List.generate(3, (i) => tester.getSize(targets.at(i)))}',
        );
        debugPrint(
          'MEASURE ${size.width} scale=$scale pills=${List.generate(3, (i) => tester.getSize(pills.at(i)))}',
        );
        await tester.tap(find.byTooltip('Usuario y preferencias'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.drag(
          find.byType(SingleChildScrollView).last,
          const Offset(0, -1600),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }
  for (final palette in RomanzaPalette.values) {
    testWidgets('audit dismiss contrast ${palette.label}', (tester) async {
      final repository = MemoryPaletteRepository()..value = palette;
      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: RomanzaApp(
            initialize: () async {},
            paletteRepository: repository,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Añadir instantánea'));
      await tester.pumpAndSettle();
      final finder = find.widgetWithText(TextButton, 'Entendido');
      final button = tester.widget<TextButton>(finder);
      final context = tester.element(finder);
      final style = button
          .defaultStyleOf(context)
          .merge(button.themeStyleOf(context))
          .merge(button.style);
      final color = style.foregroundColor!.resolve({})!;
      final bg = RomanzaColors.of(context).background;
      final a = color.computeLuminance(), b = bg.computeLuminance();
      final ratio = a > b ? (a + .05) / (b + .05) : (b + .05) / (a + .05);
      debugPrint(
        'CONTRAST ${palette.label} foreground=$color background=$bg ratio=$ratio locale=${Localizations.localeOf(context)} back=${MaterialLocalizations.of(context).backButtonTooltip}',
      );
      expect(
        ratio,
        greaterThanOrEqualTo(4.5),
        reason: 'Entendido text must remain readable',
      );
    });
  }
}
