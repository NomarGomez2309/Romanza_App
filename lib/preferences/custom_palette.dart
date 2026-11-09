import 'package:flutter/material.dart';
import '../design_system/romanza_theme.dart';

class CustomPalette {
  const CustomPalette(this.colors);
  final List<Color> colors;
  String get id => colors.map((c) => c.toARGB32().toRadixString(16)).join('-');
  static Color readable(Color background) =>
      background.computeLuminance() > .179 ? Colors.black : Colors.white;
  RomanzaColors get theme {
    final background = colors[2];
    final ink = readable(background);
    Color surface(Color seed) => Color.lerp(background, seed, .10)!;
    return RomanzaColors(
      background: background,
      ink: ink,
      secondary: ink,
      primary: colors[0],
      deep: colors[1],
      accent: colors[3],
      onPrimary: readable(colors[0]),
      note: surface(colors[1]),
      plan: surface(colors[0]),
      memory: surface(colors[3]),
      border: Color.lerp(background, ink, .35)!,
    );
  }

  List<int> toJson() => colors.map((c) => c.toARGB32()).toList();
  static CustomPalette fromJson(dynamic value) {
    final values = (value as List).cast<int>();
    if (values.length != 4 ||
        values.any((v) => v < 0xff000000 || v > 0xffffffff)) {
      throw const FormatException('Invalid palette');
    }
    return CustomPalette(values.map(Color.new).toList());
  }
}

List<CustomPalette> generatePalettes(Color first, Color second) {
  Color tone(Color seed, double lightness, [double shift = 0]) {
    final hsl = HSLColor.fromColor(seed);
    return hsl
        .withHue((hsl.hue + shift) % 360)
        .withSaturation(hsl.saturation.clamp(.25, .8))
        .withLightness(lightness)
        .toColor();
  }

  return [
    CustomPalette([
      tone(first, .65),
      tone(second, .72),
      tone(first, .97),
      tone(second, .60),
    ]),
    CustomPalette([
      tone(second, .42),
      tone(first, .60),
      tone(second, .94),
      tone(first, .58, 30),
    ]),
    CustomPalette([
      tone(first, .70, 30),
      tone(second, .55),
      tone(second, .04),
      tone(second, .75, 30),
    ]),
  ];
}
