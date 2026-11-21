import 'support/fake_auth_repository.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:romanza/app.dart';
import 'package:romanza/design_system/romanza_theme.dart';
import 'package:romanza/features/today/today_screen.dart';
import 'package:romanza/features/home_shell.dart';
import 'package:romanza/preferences/palette_controller.dart';
import 'package:romanza/preferences/palette_repository.dart';

class FailingPaletteRepository implements PaletteRepository {
  @override
  Future<RomanzaPalette> read() async => throw StateError('Read failed');
  @override
  Future<void> write(RomanzaPalette palette) async =>
      throw StateError('Write failed');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final name in ['Fredoka', 'Nunito']) {
      final loader = FontLoader(name)
        ..addFont(rootBundle.load('assets/fonts/$name.ttf'));
      await loader.load();
    }
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  Future<void> capture(WidgetTester tester, GlobalKey key, String name) async {
    if (!const bool.fromEnvironment('CAPTURE_VISUALS')) return;
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('build/visual-review/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }

  for (final size in [
    const Size(390, 844),
    const Size(412, 924),
    const Size(320, 640),
  ]) {
    for (final palette in RomanzaPalette.values) {
      testWidgets('layout ${size.width} ${palette.name}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        tester.view.padding = FakeViewPadding(
          top: size.width == 390 ? 47 : 32,
          bottom: size.width == 390 ? 34 : 24,
        );
        addTearDown(tester.view.reset);
        final repository = MemoryPaletteRepository()..value = palette;
        final key = GlobalKey();
        await tester.pumpWidget(
          RepaintBoundary(
            key: key,
            child: RomanzaApp(
              authRepository: FakeAuthRepository(),
              initialize: () async {},
              paletteRepository: repository,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Aún no hay una pareja vinculada'), findsOneWidget);
        expect(find.textContaining('328'), findsNothing);
        expect(find.text('Hoy, contigo').hitTestable(), findsOneWidget);
        expect(
          tester.getSize(find.byType(RomanzaNavigation)).height,
          lessThan(130),
        );
        final card = tester.getSize(find.byType(MomentCard).first);
        expect(card.width / card.height, closeTo(.86, .001));
        await capture(tester, key, '${palette.label}-${size.width.toInt()}');
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
          tester.getSize(find.byType(RomanzaNavigation)).height,
          lessThan(200),
        );
        if (size.width == 320 && palette == RomanzaPalette.defaultPalette) {
          await capture(tester, key, 'Default-320-texto-200');
        }
        await tester.drag(
          find.byType(SingleChildScrollView).first,
          const Offset(0, -1400),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Recuerdos').last);
        await tester.pumpAndSettle();
        expect(find.text('Lo que quieren conservar'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets(
    'palette selection survives app recreation and navigation works',
    (tester) async {
      final repository = MemoryPaletteRepository();
      await tester.pumpWidget(
        RomanzaApp(
          authRepository: FakeAuthRepository(),
          initialize: () async {},
          paletteRepository: repository,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Usuario y preferencias'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Temas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Forest'));
      await tester.pumpAndSettle();
      expect(repository.value, RomanzaPalette.forest);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Planes').last);
      await tester.pumpAndSettle();
      expect(find.textContaining('Todavía no hay planes.'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        RomanzaApp(
          authRepository: FakeAuthRepository(),
          initialize: () async {},
          paletteRepository: repository,
        ),
      );
      await tester.pumpAndSettle();
      expect(
        Theme.of(
          tester.element(find.byType(TodayScreen)),
        ).extension<RomanzaColors>()!.primary,
        RomanzaColors.forPalette(RomanzaPalette.forest).primary,
      );
    },
  );

  testWidgets('touch targets and labels are accessible', (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        RomanzaApp(
          authRepository: FakeAuthRepository(),
          initialize: () async {},
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('preferences and empty memories remain readable', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: RomanzaApp(
          authRepository: FakeAuthRepository(),
          initialize: () async {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Usuario y preferencias'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Temas'));
    await tester.pumpAndSettle();
    await capture(tester, key, 'Preferencias');
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Recuerdos').last);
    await tester.pumpAndSettle();
    await capture(tester, key, 'Recuerdos-vacio');
    expect(tester.takeException(), isNull);
  });

  test('preference failures do not claim a successful save', () async {
    final controller = PaletteController(FailingPaletteRepository());
    await controller.load();
    expect(controller.error, isNotNull);
    await controller.select(RomanzaPalette.neo);
    expect(controller.palette, RomanzaPalette.defaultPalette);
    expect(controller.saving, isFalse);
    expect(controller.error, contains('No se pudo guardar'));
    controller.dispose();
  });

  test('body and primary text colors meet 4.5 contrast', () {
    double contrast(Color a, Color b) {
      final x = a.computeLuminance();
      final y = b.computeLuminance();
      return x > y ? (x + .05) / (y + .05) : (y + .05) / (x + .05);
    }

    for (final palette in RomanzaPalette.values) {
      final c = RomanzaColors.forPalette(palette);
      for (final background in [c.background, c.note, c.plan, c.memory]) {
        expect(contrast(c.ink, background), greaterThanOrEqualTo(4.5));
        expect(contrast(c.secondary, background), greaterThanOrEqualTo(4.5));
      }
      expect(contrast(c.onPrimary, c.primary), greaterThanOrEqualTo(4.5));
    }
  });
}
