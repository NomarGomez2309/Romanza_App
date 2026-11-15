// Regenerate with: flutter test tools/branding/generate_launcher_sources_test.dart
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('render approved fixed launcher artwork', (tester) async {
    tester.view.physicalSize = const Size(1024, 1024);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final source = File(
      'assets/launcher/romanza-symbol.svg',
    ).readAsStringSync();
    for (final name in ['icon', 'foreground', 'monochrome']) {
      final key = GlobalKey();
      final opaque = name == 'icon';
      // 500/1024 * 108 = 52.73dp width. The complete bounding rectangle
      // fits inside Android's centered 66dp-diameter safe circle.
      final width = opaque ? 650.0 : 500.0;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: RepaintBoundary(
            key: key,
            child: ColoredBox(
              color: opaque ? const Color(0xFFFFF3E3) : Colors.transparent,
              child: Center(
                child: SizedBox(
                  width: width,
                  height: width * 233 / 334,
                  child: SvgPicture.string(
                    source,
                    fit: BoxFit.contain,
                    colorFilter: name == 'monochrome'
                        ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 1);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await File(
          'assets/launcher/$name.png',
        ).writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }
  });
}
