import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

Uint8List squarePhotoBytes(({Uint8List bytes, bool mirror}) input) {
  final decoded = img.decodeImage(input.bytes);
  if (decoded == null) throw const FormatException('No se pudo leer la foto');
  final oriented = img.bakeOrientation(decoded);
  final side = math.min(oriented.width, oriented.height);
  var square = img.copyCrop(
    oriented,
    x: (oriented.width - side) ~/ 2,
    y: (oriented.height - side) ~/ 2,
    width: side,
    height: side,
  );
  if (input.mirror) square = img.flipHorizontal(square);
  // PNG avoids introducing a lossy quality policy not specified by the product.
  return Uint8List.fromList(img.encodePng(square));
}

Future<File> prepareSquarePhoto(String source, {required bool mirror}) async {
  final file = File(source);
  final bytes = await compute(squarePhotoBytes, (
    bytes: await file.readAsBytes(),
    mirror: mirror,
  ));
  final output = File('$source.square.png');
  await output.writeAsBytes(bytes, flush: true);
  return output;
}
