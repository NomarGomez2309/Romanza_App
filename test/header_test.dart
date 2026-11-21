import 'support/fake_auth_repository.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:romanza/app.dart';
import 'package:romanza/design_system/header_logo.dart';
import 'package:romanza/design_system/romanza_theme.dart';
import 'package:romanza/features/settings/settings_sheet.dart';
import 'package:romanza/features/today/today_screen.dart';
import 'package:romanza/preferences/custom_palette.dart';
import 'package:romanza/preferences/palette_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final name in ['Fredoka', 'Nunito']) {
      await (FontLoader(
        name,
      )..addFont(rootBundle.load('assets/fonts/$name.ttf'))).load();
    }
  });
  Future<void> capture(WidgetTester tester, GlobalKey key, String name) async {
    if (!const bool.fromEnvironment('CAPTURE_VISUALS')) return;
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('build/header-validation/after/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }

  for (final size in [const Size(390, 844), const Size(412, 924)]) {
    for (final palette in RomanzaPalette.values) {
      for (final scale in [1.0, 2.0]) {
        for (final insets in [false, true]) {
          testWidgets(
            'header ${size.width} ${palette.label} scale $scale insets $insets',
            (tester) async {
              tester.view.physicalSize = size;
              tester.view.devicePixelRatio = 1;
              final top = insets ? (size.width == 390 ? 47.0 : 32.0) : 0.0;
              tester.view.padding = FakeViewPadding(
                top: top,
                bottom: insets ? (size.width == 390 ? 34 : 24) : 0,
              );
              tester.platformDispatcher.textScaleFactorTestValue = scale;
              addTearDown(tester.view.reset);
              addTearDown(
                tester.platformDispatcher.clearTextScaleFactorTestValue,
              );
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
              expect(find.text('romanza'), findsNothing);
              final logo = tester.getRect(find.byType(HeaderLogo));
              final header = tester.getRect(find.byType(CoupleHeader));
              final group = tester.getRect(
                find.byKey(const ValueKey('header-avatar-group')),
              );
              final target = tester.getRect(
                find.byKey(const ValueKey('header-profile-target')),
              );
              final first = tester.getRect(
                find.byKey(const ValueKey('header-avatar-user')),
              );
              final second = tester.getRect(
                find.byKey(const ValueKey('header-avatar-partner')),
              );
              expect(logo.size, const Size(41.6, 29.25));
              expect(header.height, 72);
              expect(logo.left, 16);
              expect(group.right, closeTo(size.width - 16, .001));
              expect(group.width, closeTo(76.7, .001));
              expect(first.width, closeTo(41.6, .001));
              expect(first.size, second.size);
              expect(first.right - second.left, closeTo(6.5, .001));
              expect(logo.center.dy, closeTo(group.center.dy, .001));
              expect(target.height, greaterThanOrEqualTo(48));
              expect(
                tester.getSize(find.byKey(const ValueKey('header-union'))),
                const Size(15.6, 15.6),
              );
              expect(tester.getTopLeft(find.text('Hoy, contigo')).dy, top + 88);
              final branding = Theme.of(
                tester.element(find.byType(HeaderLogo)),
              ).extension<HeaderLogoTheme>()!;
              expect(
                branding.asset,
                'assets/logos/Romanza-${palette.label}.svg',
              );
              expect(branding.monochrome, isNull);
              expect(tester.takeException(), isNull);
              if (insets) {
                await capture(
                  tester,
                  key,
                  '${palette.label}-${size.width.toInt()}-${scale == 1 ? '100' : '200'}',
                );
              }
              await tester.tap(find.byTooltip('Usuario y preferencias'));
              await tester.pumpAndSettle();
              expect(find.byType(SettingsSheet), findsOneWidget);
              expect(tester.takeException(), isNull);
            },
          );
        }
      }
    }
  }
  testWidgets(
    'image decoding, circular crop and failed-image fallback retain geometry',
    (tester) async {
      final fixture = img.Image(width: 160, height: 80);
      img.fill(fixture, color: img.ColorRgb8(120, 80, 50));
      final image = MemoryImage(Uint8List.fromList(img.encodePng(fixture)));
      var opened = 0;
      for (final provider in <ImageProvider>[
        image,
        MemoryImage(Uint8List.fromList([0, 1, 2])),
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: romanzaTheme(RomanzaPalette.forest),
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: CoupleHeader(
                  onProfile: () => opened++,
                  userImage: provider,
                  partnerImage: provider,
                ),
              ),
            ),
          ),
        );
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 100));
        });
        await tester.pumpAndSettle();
        expect(find.byType(ClipOval), findsNWidgets(2));
        for (final photo in tester.widgetList<Image>(find.byType(Image))) {
          expect(photo.fit, BoxFit.cover);
          expect(photo.image, same(provider));
        }
        expect(
          tester.getSize(find.byKey(const ValueKey('header-avatar-user'))),
          const Size(41.6, 41.6),
        );
        await tester.tap(find.byTooltip('Usuario y preferencias'));
        expect(tester.takeException(), isNull);
      }
      expect(opened, 2);
    },
  );
  testWidgets(
    'theme changes preserve geometry and Custom keeps the prior ink policy',
    (tester) async {
      Rect? previous;
      for (final palette in RomanzaPalette.values) {
        await tester.pumpWidget(
          MaterialApp(
            theme: romanzaTheme(palette),
            home: Scaffold(body: CoupleHeader(onProfile: () {})),
          ),
        );
        await tester.pumpAndSettle();
        final rect = tester.getRect(find.byType(HeaderLogo));
        if (previous != null) expect(rect, previous);
        previous = rect;
        expect(
          tester
              .widget<SvgPicture>(
                find.descendant(
                  of: find.byType(HeaderLogo),
                  matching: find.byType(SvgPicture),
                ),
              )
              .colorFilter,
          isNull,
        );
      }
      final custom = CustomPalette([
        Colors.purple,
        Colors.teal,
        Colors.white,
        Colors.orange,
      ]).theme;
      await tester.pumpWidget(
        MaterialApp(
          theme: romanzaTheme(RomanzaPalette.neo, custom: custom),
          home: Scaffold(body: CoupleHeader(onProfile: () {})),
        ),
      );
      await tester.pumpAndSettle();
      final svg = tester.widget<SvgPicture>(
        find.descendant(
          of: find.byType(HeaderLogo),
          matching: find.byType(SvgPicture),
        ),
      );
      expect(svg.colorFilter, ColorFilter.mode(custom.ink, BlendMode.srcIn));
      expect(tester.getRect(find.byType(HeaderLogo)), previous);
    },
  );
}
