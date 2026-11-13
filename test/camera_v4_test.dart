import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:romanza/design_system/romanza_theme.dart';
import 'package:romanza/features/camera/camera_screen.dart';
import 'package:romanza/features/camera/camera_flash.dart';
import 'package:romanza/features/camera/square_photo.dart';

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
  test(
    'square crop preserves center, removes outside pixels and mirrors front',
    () {
      final input = img.Image(width: 6, height: 4);
      for (var y = 0; y < 4; y++) {
        for (var x = 0; x < 6; x++) {
          input.setPixelRgb(x, y, x * 40, y * 50, 0);
        }
      }
      final bytes = img.encodePng(input);
      final back = img.decodePng(
        squarePhotoBytes((bytes: bytes, mirror: false)),
      )!;
      final front = img.decodePng(
        squarePhotoBytes((bytes: bytes, mirror: true)),
      )!;
      expect(back.width, 4);
      expect(back.height, 4);
      expect(back.getPixel(0, 0).r, 40);
      expect(back.getPixel(3, 0).r, 160);
      expect(front.getPixel(0, 0).r, 160);
      expect(front.getPixel(3, 0).r, 40);
      expect(front.getPixel(0, 3).g, 150);
    },
  );
  test('EXIF is baked before the square crop', () {
    final input = img.Image(width: 6, height: 4);
    for (var y = 0; y < 4; y++) {
      for (var x = 0; x < 6; x++) {
        input.setPixelRgb(x, y, x * 40, y * 50, 0);
      }
    }
    input.exif.imageIfd.orientation = 6;
    final decoded = img.decodeJpg(img.encodeJpg(input, quality: 100))!;
    final baked = img.bakeOrientation(decoded);
    final result = img.decodePng(
      squarePhotoBytes((
        bytes: img.encodeJpg(input, quality: 100),
        mirror: false,
      )),
    )!;
    expect(result.width, 4);
    expect(result.height, 4);
    expect(result.getPixel(0, 0).r, baked.getPixel(0, 1).r);
    expect(result.getPixel(0, 0).g, baked.getPixel(0, 1).g);
  });
  for (final fail in [false, true]) {
    test(
      'screen flash restores brightness and overlay on capture failure=$fail',
      () async {
        final events = <String>[];
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(CameraFlash.channel, (call) async {
              events.add(call.method);
              return null;
            });
        final operation = CameraFlash().illuminate<int>(
          shoot: () async {
            events.add('capture');
            if (fail) throw StateError('capture');
            return 7;
          },
          show: (visible) async {
            events.add('white=$visible');
          },
        );
        if (fail) {
          await expectLater(operation, throwsStateError);
        } else {
          expect(await operation, 7);
        }
        expect(events, [
          'beginScreenFlash',
          'white=true',
          'capture',
          'endScreenFlash',
          'white=false',
        ]);
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(CameraFlash.channel, null);
      },
    );
  }
  for (final size in [
    const Size(390, 844),
    const Size(412, 924),
    const Size(320, 640),
    const Size(844, 390),
  ]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('same square before and after capture $size scale$scale', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        tester.view.padding = FakeViewPadding(
          top: size.width == 390 ? 47 : 32,
          bottom: size.width == 390 ? 34 : 24,
        );
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final caption = TextEditingController();
        addTearDown(caption.dispose);
        final key = GlobalKey();
        Widget app(bool review) => RepaintBoundary(
          key: key,
          child: MaterialApp(
            locale: const Locale('es'),
            supportedLocales: const [Locale('es')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            theme: romanzaTheme(RomanzaPalette.forest),
            home: Scaffold(
              body: SafeArea(
                child: CameraComposition(
                  preview: const ColoredBox(color: Color(0xffd5e8e6)),
                  reviewing: review,
                  caption: caption,
                  onClose: () {},
                  onFlash: () {},
                  onCapture: () {},
                  onFlip: () {},
                  onRepeat: () {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpWidget(app(false));
        await tester.pumpAndSettle();
        final square = find.byKey(const ValueKey('square-viewport'));
        final before = tester.getRect(square);
        expect(before.width, before.height);
        if (size.width < 500) expect(before.width, size.width - 32);
        expect(find.byTooltip('Abrir galería'), findsNothing);
        expect(tester.takeException(), isNull);
        if (scale == 1 && size.width == 390) {
          expect(before.top, 158);
        }
        await tester.pumpWidget(app(true));
        await tester.pumpAndSettle();
        final after = tester.getRect(square);
        expect(after.size, before.size);
        if (scale == 1) expect(after.top, before.top);
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.text('Repetir'));
        expect(find.text('Repetir').hitTestable(), findsOneWidget);
        if (const bool.fromEnvironment('CAPTURE_VISUALS') &&
            scale == 1 &&
            size.width < 500) {
          await tester.runAsync(() async {
            final image =
                await (key.currentContext!.findRenderObject()!
                        as RenderRepaintBoundary)
                    .toImage(pixelRatio: 2);
            final data = await image.toByteData(format: ui.ImageByteFormat.png);
            final file = File(
              'build/visual-review/camera-v4-${size.width.toInt()}.png',
            );
            await file.parent.create(recursive: true);
            await file.writeAsBytes(data!.buffer.asUint8List());
            image.dispose();
          });
        }
        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byType(TextField));
        await tester.enterText(
          find.byType(TextField),
          'Un texto largo para revisar la adaptación del teclado y el desplazamiento.',
        );
        await tester.ensureVisible(find.text('Repetir'));
        expect(tester.takeException(), isNull);
      });
    }
  }
}
