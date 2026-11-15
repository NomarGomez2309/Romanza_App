import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;

void main() {
  final dir = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';
  final contents = jsonDecode(File('$dir/Contents.json').readAsStringSync());
  var count = 0;
  for (final item in contents['images']) {
    if (item['filename'] == null) continue;
    final image = img.decodePng(
      File('$dir/${item['filename']}').readAsBytesSync(),
    )!;
    final expected =
        (double.parse(item['size'].split('x')[0]) *
                double.parse(item['scale'].replaceAll('x', '')))
            .round();
    if (image.width != expected || image.height != expected || image.hasAlpha) {
      throw StateError('${item['filename']}: invalid size/alpha');
    }
    count++;
  }
  stdout.writeln(
    'iOS: $count icon entries have correct dimensions and no alpha channel.',
  );
  for (final name in ['foreground', 'monochrome']) {
    final image = img.decodePng(
      File('assets/launcher/$name.png').readAsBytesSync(),
    )!;
    var radius = 0.0;
    for (final p in image) {
      if (p.a > 0) {
        radius = max(
          radius,
          sqrt(pow(p.x - 511.5, 2) + pow(p.y - 511.5, 2)) * 108 / 1024,
        );
      }
      if (name == 'monochrome' &&
          p.a > 0 &&
          (p.r != 255 || p.g != 255 || p.b != 255)) {
        throw StateError('Not monochrome');
      }
    }
    if (radius > 33) throw StateError('Outside Android safe zone: $radius');
    stdout.writeln(
      'Android $name: maximum radius ${radius.toStringAsFixed(2)}dp, safe limit 33dp.',
    );
  }
}
