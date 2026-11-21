import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:romanza/design_system/romanza_theme.dart';
import 'package:romanza/preferences/preferences_screen.dart';
import 'package:romanza/preferences/custom_palette_screen.dart';
import 'package:romanza/preferences/custom_duo_screen.dart';
import 'package:romanza/preferences/hsv_picker.dart';
import 'package:romanza/preferences/palette_controller.dart';
import 'package:romanza/preferences/palette_repository.dart';
import 'package:romanza/preferences/preferences_store.dart';

void main() {
  setUpAll(() async {
    for (final font in ['Fredoka', 'Nunito']) {
      await (FontLoader(
        font,
      )..addFont(rootBundle.load('assets/fonts/$font.ttf'))).load();
    }
  });
  test(
    'HSV ring preserves saturation and brightness; inner plane edits both',
    () {
      final seed = HSVColor.fromAHSV(1, 210, .4, .8).toColor();
      Color? result;
      final picker = HsvPicker(
        colors: [seed, null],
        active: 0,
        onChanged: (c) => result = c,
      );
      picker.pick(const Offset(106, 206));
      final hue = HSVColor.fromColor(result!);
      expect(hue.hue, closeTo(90, 1));
      expect(hue.saturation, closeTo(.4, .02));
      expect(hue.value, closeTo(.8, .02));
      picker.pick(const Offset(106, 106));
      final plane = HSVColor.fromColor(result!);
      expect(plane.hue, closeTo(210, 1));
      expect(plane.saturation, closeTo(.5, .02));
      expect(plane.value, closeTo(.5, .02));
    },
  );
  testWidgets(
    'themes open Custom without applying it, then save and restore the selected palette',
    (tester) async {
      final store = MemoryPreferencesStore();
      final controller = PaletteController(
        MemoryPaletteRepository(),
        store: store,
      );
      await controller.load();
      await tester.pumpWidget(
        MaterialApp(
          theme: romanzaTheme(RomanzaPalette.forest),
          home: PreferencesScreen(controller: controller),
        ),
      );
      await tester.tap(find.text('Forest'));
      await tester.pumpAndSettle();
      expect(controller.palette, RomanzaPalette.forest);
      expect(find.byType(ThemePaletteCard), findsNWidgets(4));
      await tester.ensureVisible(find.text('Custom'));
      await tester.tap(find.text('Custom'));
      await tester.pumpAndSettle();
      expect(find.byType(CustomPaletteScreen), findsOneWidget);
      expect(controller.palette, RomanzaPalette.forest);
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Generar paletas'),
            )
            .onPressed,
        isNull,
      );
      await choose(tester, 1, '9FA0FF');
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Generar paletas'),
            )
            .onPressed,
        isNull,
      );
      await choose(tester, 2, 'FF7171');
      await tester.ensureVisible(find.text('Generar paletas'));
      await tester.tap(find.text('Generar paletas'));
      await tester.pumpAndSettle();
      expect(find.byType(PaletteSample), findsNWidgets(3));
      await tester.ensureVisible(find.byType(PaletteSample).first);
      await tester.tap(find.byType(PaletteSample).first);
      await tester.pumpAndSettle();
      expect(controller.activeCustomId, isNull);
      await tester.ensureVisible(find.text('Guardar paleta'));
      await tester.tap(find.text('Guardar paleta'));
      await tester.pumpAndSettle();
      expect(find.byType(PreferencesScreen), findsOneWidget);
      expect(controller.bank, hasLength(1));
      final restored = PaletteController(
        MemoryPaletteRepository(),
        store: store,
      );
      await restored.load();
      expect(restored.activeCustomId, controller.activeCustomId);
      expect(restored.bank.single.id, controller.bank.single.id);
      await tester.pumpWidget(const SizedBox());
      restored.dispose();
      controller.dispose();
    },
  );
  for (final width in [390.0, 412.0]) {
    for (final scale in [1.0, 2.0]) {
      for (final palette in RomanzaPalette.values) {
        testWidgets(
          'duo fits $width scale $scale $palette without impersonating a partner',
          (tester) async {
            tester.view.physicalSize = Size(width, width == 390 ? 844 : 924);
            tester.view.devicePixelRatio = 1;
            tester.view.padding = FakeViewPadding(
              top: width == 390 ? 47 : 32,
              bottom: width == 390 ? 34 : 24,
            );
            tester.platformDispatcher.textScaleFactorTestValue = scale;
            addTearDown(tester.view.reset);
            addTearDown(
              tester.platformDispatcher.clearTextScaleFactorTestValue,
            );
            final semantics = tester.ensureSemantics();
            await tester.pumpWidget(
              MaterialApp(
                theme: romanzaTheme(palette),
                home: const CustomDuoScreen(),
              ),
            );
            await tester.pumpAndSettle();
            expect(find.text('Sin elegir'), findsNWidgets(2));
            await tester.ensureVisible(find.bySemanticsLabel('Lavanda'));
            await tester.tap(find.bySemanticsLabel('Lavanda'));
            await tester.pumpAndSettle();
            expect(find.text('Por confirmar'), findsOneWidget);
            expect(find.text('Confirmado'), findsNothing);
            await tester.ensureVisible(find.text('Generar combinaciones'));
            final generate = tester.widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Generar combinaciones'),
            );
            expect(generate.onPressed, isNull);
            expect(tester.takeException(), isNull);
            semantics.dispose();
          },
        );
      }
    }
  }
}

Future<void> choose(WidgetTester tester, int index, String hex) async {
  await tester.ensureVisible(find.text('Color $index'));
  await tester.tap(find.text('Color $index'));
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Editar valores de Color $index'));
  await tester.tap(find.text('Editar valores de Color $index'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), hex);
  await tester.tap(find.text('Aplicar'));
  await tester.pumpAndSettle();
}
