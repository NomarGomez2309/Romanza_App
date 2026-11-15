import 'romanza_icon.dart';
import 'header_logo.dart';
import 'package:flutter/material.dart';

enum RomanzaPalette { defaultPalette, forest, neo }

extension PaletteLabel on RomanzaPalette {
  String get label => switch (this) {
    RomanzaPalette.defaultPalette => 'Default',
    RomanzaPalette.forest => 'Forest',
    RomanzaPalette.neo => 'Neo',
  };
}

abstract final class RomanzaSpace {
  static const margin = 16.0;
  static const gap = 8.0;
  static const radius = 16.0;
  static const maxWidth = 552.0;
  static const photoRatio = .86;
}

abstract final class RomanzaType {
  static TextStyle heading(double size, double line, double weight) =>
      TextStyle(
        fontFamily: 'Fredoka',
        fontSize: size,
        height: line / size,
        fontVariations: [FontVariation('wght', weight)],
      );
  static final brand = heading(30, 36, 700);
  static final greeting = heading(34, 40, 600);
  static final section = heading(25, 32, 600);
  static final card = heading(16, 20, 500);
  static final memory = heading(15, 20, 500);
  static const body = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 14,
    height: 20 / 14,
  );
  static const days = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 15,
    height: 20 / 15,
  );
  static const caption = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 12,
    height: 20 / 12,
  );
  static const time = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 12,
    height: 16 / 12,
  );
  static const navigation = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 14,
    letterSpacing: 0,
    height: 18 / 14,
  );
}

@immutable
class RomanzaColors extends ThemeExtension<RomanzaColors> {
  const RomanzaColors({
    required this.background,
    required this.ink,
    required this.secondary,
    required this.primary,
    required this.deep,
    required this.accent,
    required this.onPrimary,
    required this.note,
    required this.plan,
    required this.memory,
    required this.border,
  });

  final Color background, ink, secondary, primary, deep, accent, onPrimary;
  final Color note, plan, memory, border;
  Color get onAccent {
    final light = accent.computeLuminance();
    final dark = ink.computeLuminance();
    final contrast = (light > dark
        ? (light + .05) / (dark + .05)
        : (dark + .05) / (light + .05));
    if (contrast >= 4.5) return ink;
    return light > .179 ? Colors.black : Colors.white;
  }

  static RomanzaColors of(BuildContext context) =>
      Theme.of(context).extension<RomanzaColors>()!;

  static RomanzaColors forPalette(RomanzaPalette palette) => switch (palette) {
    RomanzaPalette.defaultPalette => const RomanzaColors(
      background: Color(0xFFFFF3E3),
      ink: Color(0xFF302C46),
      secondary: Color(0xFF59536C),
      primary: Color(0xFF9FA0FF),
      deep: Color(0xFFD5E8E6),
      accent: Color(0xFFFF7171),
      onPrimary: Color(0xFF302C46),
      note: Color(0xFFD5E8E6),
      plan: Color(0xFFE4DEFA),
      memory: Color(0xFFF6E9DB),
      border: Color(0xFFD7CFC7),
    ),
    RomanzaPalette.forest => const RomanzaColors(
      background: Color(0xFFF3F6F4),
      ink: Color(0xFF202A13),
      secondary: Color(0xFF4D5E26),
      primary: Color(0xFF7D8D39),
      deep: Color(0xFF5B6E2C),
      accent: Color(0xFFFF5A22),
      onPrimary: Color(0xFF111A08),
      note: Color(0xFFE8ECDE),
      plan: Color(0xFFDEE5CD),
      memory: Color(0xFFE9EDE4),
      border: Color(0xFFD8DFCC),
    ),
    RomanzaPalette.neo => const RomanzaColors(
      background: Color(0xFF000000),
      ink: Color(0xFFEEEEEE),
      secondary: Color(0xFFC5D3BC),
      primary: Color(0xFF08CB00),
      deep: Color(0xFF253900),
      accent: Color(0xFF08CB00),
      onPrimary: Color(0xFF000000),
      note: Color(0xFF182411),
      plan: Color(0xFF253900),
      memory: Color(0xFF121A0E),
      border: Color(0xFF3F532D),
    ),
  };

  @override
  RomanzaColors copyWith() => this;

  @override
  RomanzaColors lerp(covariant RomanzaColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return RomanzaColors(
      background: mix(background, other.background),
      ink: mix(ink, other.ink),
      secondary: mix(secondary, other.secondary),
      primary: mix(primary, other.primary),
      deep: mix(deep, other.deep),
      accent: mix(accent, other.accent),
      onPrimary: mix(onPrimary, other.onPrimary),
      note: mix(note, other.note),
      plan: mix(plan, other.plan),
      memory: mix(memory, other.memory),
      border: mix(border, other.border),
    );
  }
}

ThemeData romanzaTheme(RomanzaPalette palette, {RomanzaColors? custom}) {
  final c = custom ?? RomanzaColors.forPalette(palette);
  final dark = c.background.computeLuminance() < .179;
  final scheme =
      ColorScheme.fromSeed(
        seedColor: c.primary,
        brightness: dark ? Brightness.dark : Brightness.light,
      ).copyWith(
        primary: c.primary,
        onPrimary: c.onPrimary,
        surface: c.background,
        onSurface: c.ink,
        onSurfaceVariant: c.secondary,
        outline: c.secondary,
        outlineVariant: c.border,
        surfaceTint: Colors.transparent,
      );
  return ThemeData(
    actionIconTheme: ActionIconThemeData(
      backButtonIconBuilder: (_) => const RomanzaIcon(RomanzaSymbol.arrowLeft),
      closeButtonIconBuilder: (_) =>
          const RomanzaIcon(RomanzaSymbol.x, size: 22),
    ),
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.background,
    fontFamily: 'Nunito',
    extensions: [
      c,
      HeaderLogoTheme(
        asset:
            'assets/logos/Romanza-${custom == null ? palette.label : 'Default'}.svg',
        monochrome: custom == null ? null : c.ink,
      ),
    ],
    textTheme: TextTheme(
      bodyMedium: RomanzaType.body.copyWith(color: c.ink),
      titleLarge: RomanzaType.section.copyWith(color: c.ink),
    ),
    iconTheme: IconThemeData(color: c.ink, size: 26),
    dividerColor: c.border,
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: c.ink,
        minimumSize: const Size(48, 48),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: c.ink,
        minimumSize: const Size(48, 48),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
    ),
    splashFactory: InkRipple.splashFactory,
    snackBarTheme: SnackBarThemeData(
      backgroundColor: c.ink,
      contentTextStyle: RomanzaType.body.copyWith(color: c.background),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: c.background,
      foregroundColor: c.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.background,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
    ),
  );
}
