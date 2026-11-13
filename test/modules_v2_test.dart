import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:romanza/app.dart';
import 'package:romanza/design_system/romanza_theme.dart';
import 'package:romanza/features/camera/draft_repository.dart';
import 'package:romanza/features/camera/camera_screen.dart';
import 'package:romanza/features/settings/settings_sheet.dart';
import 'package:romanza/preferences/custom_palette.dart';
import 'package:romanza/preferences/palette_controller.dart';
import 'package:romanza/preferences/palette_repository.dart';
import 'package:romanza/preferences/preferences_screen.dart';
import 'package:romanza/preferences/preferences_store.dart';

class FailedStore implements PreferencesStore {
  @override
  Future<String?> read() async => null;
  @override
  Future<void> write(String value) async =>
      throw const FileSystemException('full');
}

class FailedDraftRepository implements DraftRepository {
  @override
  Future<PhotoDraft?> read() async =>
      throw const FileSystemException('unavailable');
  @override
  Future<PhotoDraft> importPhoto(String source) async =>
      throw const FileSystemException('unavailable');
  @override
  Future<void> save(PhotoDraft draft) async =>
      throw const FileSystemException('unavailable');
  @override
  Future<void> delete() async => throw const FileSystemException('unavailable');
}

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
  Future<void> capture(WidgetTester tester, GlobalKey key, String name) async {
    if (!const bool.fromEnvironment('CAPTURE_VISUALS')) return;
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('build/visual-review/v2-$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }

  test('three distinct proposals, contrast across all functional surfaces', () {
    double contrast(Color a, Color b) {
      final x = a.computeLuminance(), y = b.computeLuminance();
      return (x > y ? x + .05 : y + .05) / (x > y ? y + .05 : x + .05);
    }

    for (final a in [
      Colors.white,
      Colors.black,
      Colors.red,
      Colors.green,
      Colors.blue,
    ]) {
      for (final b in [a, Colors.black, Colors.yellow]) {
        final proposals = generatePalettes(a, b);
        expect(proposals.map((p) => p.id).toSet(), hasLength(3));
        for (final p in proposals) {
          final c = p.theme;
          for (final surface in [c.background, c.note, c.plan, c.memory]) {
            expect(contrast(c.ink, surface), greaterThanOrEqualTo(4.5));
          }
          expect(contrast(c.onPrimary, c.primary), greaterThanOrEqualTo(4.5));
        }
      }
    }
  });
  test(
    'palette bank, active choice and language persist without duplicates',
    () async {
      final store = MemoryPreferencesStore();
      final legacy = MemoryPaletteRepository()..value = RomanzaPalette.forest;
      final first = PaletteController(legacy, store: store);
      await first.load();
      expect(first.palette, RomanzaPalette.forest);
      final value = generatePalettes(Colors.blue, Colors.red).first;
      expect(await first.saveCustom(value), isTrue);
      await first.saveCustom(value);
      await first.setLanguage(false);
      final second = PaletteController(legacy, store: store);
      await second.load();
      expect(second.bank, hasLength(1));
      expect(second.custom!.id, value.id);
      expect(second.systemLanguage, isFalse);
      await second.select(RomanzaPalette.neo);
      final third = PaletteController(legacy, store: store);
      await third.load();
      expect(third.custom, isNull);
      expect(third.palette, RomanzaPalette.neo);
      expect(third.bank, hasLength(1));
      first.dispose();
      second.dispose();
      third.dispose();
    },
  );
  test('failed custom save and language keep last confirmed state', () async {
    final controller = PaletteController(
      MemoryPaletteRepository(),
      store: FailedStore(),
    );
    expect(
      await controller.saveCustom(
        generatePalettes(Colors.blue, Colors.red).first,
      ),
      isFalse,
    );
    expect(controller.bank, isEmpty);
    expect(controller.custom, isNull);
    await controller.setLanguage(false);
    expect(controller.systemLanguage, isTrue);
    await controller.select(RomanzaPalette.neo);
    expect(controller.palette, RomanzaPalette.defaultPalette);
    expect(controller.error, isNotNull);
    controller.dispose();
  });
  test(
    'private draft survives restart, replacement and deletion preserve original',
    () async {
      final root = await Directory.systemTemp.createTemp('romanza-draft-test-');
      try {
        final source = File('${root.path}/source.jpg');
        await source.writeAsBytes([1, 2, 3, 4]);
        final repo = LocalDraftRepository(directory: root);
        expect(await repo.read(), isNull);
        final photo = await repo.importPhoto(source.path);
        await repo.save(photo.withCaption('Nuestro día 🌿'));
        final restored = await LocalDraftRepository(directory: root).read();
        expect(restored!.caption, 'Nuestro día 🌿');
        expect(await File(restored.path).readAsBytes(), [1, 2, 3, 4]);
        await expectLater(
          repo.importPhoto('${root.path}/absent.jpg'),
          throwsA(isA<FileSystemException>()),
        );
        expect((await repo.read())!.path, restored.path);
        final replacement = await repo.importPhoto(source.path);
        expect(replacement.path, isNot(restored.path));
        expect(await File(restored.path).exists(), isFalse);
        await repo.delete();
        expect(await repo.read(), isNull);
        expect(await File(replacement.path).exists(), isFalse);
        expect(await source.exists(), isTrue);
      } finally {
        await root.delete(recursive: true);
      }
    },
  );
  for (final size in [
    const Size(390, 844),
    const Size(412, 924),
    const Size(320, 640),
    const Size(844, 390),
  ]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('settings and preferences fit $size scale $scale', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        tester.view.padding = const FakeViewPadding(top: 32, bottom: 24);
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final key = GlobalKey();
        await tester.pumpWidget(
          RepaintBoundary(
            key: key,
            child: RomanzaApp(initialize: () async {}),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Usuario y preferencias'));
        await tester.pumpAndSettle();
        expect(find.byType(SettingsSheet), findsOneWidget);
        expect(find.byType(ListTile), findsNWidgets(6));
        expect(tester.takeException(), isNull);
        if (scale == 1) {
          await capture(tester, key, 'settings-${size.width.toInt()}');
        }
        await tester.ensureVisible(find.text('Preferencias'));
        await tester.tap(find.text('Preferencias'));
        await tester.pumpAndSettle();
        expect(find.byType(PreferencesScreen), findsOneWidget);
        expect(find.byTooltip('Atrás'), findsOneWidget);
        await tester.ensureVisible(find.text('Generar paletas'));
        await tester.tap(find.text('Generar paletas'));
        await tester.pumpAndSettle();
        expect(find.byType(PaletteSample), findsNWidgets(3));
        expect(
          tester
              .widget<FilledButton>(
                find.widgetWithText(FilledButton, 'Guardar paleta'),
              )
              .onPressed,
          isNull,
        );
        await tester.ensureVisible(find.byType(PaletteSample).first);
        await tester.tap(find.byType(PaletteSample).first);
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<FilledButton>(
                find.widgetWithText(FilledButton, 'Guardar paleta'),
              )
              .onPressed,
          isNotNull,
        );
        expect(tester.takeException(), isNull);
        if (scale == 1) {
          await capture(tester, key, 'preferences-${size.width.toInt()}');
        }
      });
    }
  }
  testWidgets('camera starts safely and exposes recoverable storage failure', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: romanzaTheme(RomanzaPalette.forest),
        home: InstantCameraScreen(repository: FailedDraftRepository()),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.textContaining('No pudimos completar'), findsOneWidget);
    expect(find.text('Galería'), findsNothing);
    expect(find.text('Volver'), findsOneWidget);
    expect(find.byTooltip('Abrir galería'), findsNothing);
    expect(find.byTooltip('Girar cámara'), findsOneWidget);
    final semantics = tester.ensureSemantics();
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    semantics.dispose();
  });
  testWidgets('editing seed invalidates generated proposals', (tester) async {
    final controller = PaletteController(
      MemoryPaletteRepository(),
      store: MemoryPreferencesStore(),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: romanzaTheme(RomanzaPalette.defaultPalette),
        home: PreferencesScreen(controller: controller),
      ),
    );
    await tester.tap(find.text('Generar paletas'));
    await tester.pumpAndSettle();
    expect(find.byType(PaletteSample), findsNWidgets(3));
    await tester.tap(find.text('Color 1'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'ZZZZZZ');
    await tester.tap(find.text('Aplicar'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Introduce seis'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '123456');
    await tester.tap(find.text('Aplicar'));
    await tester.pumpAndSettle();
    expect(find.byType(PaletteSample), findsNothing);
    controller.dispose();
  });
}
