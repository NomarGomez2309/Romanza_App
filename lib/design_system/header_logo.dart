import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Header-only branding; does not affect the launcher icon or splash.
@immutable
class HeaderLogoTheme extends ThemeExtension<HeaderLogoTheme> {
  const HeaderLogoTheme({required this.asset, this.monochrome});
  final String asset;
  // Custom keeps the existing header foreground, without inventing a palette.
  final Color? monochrome;

  @override
  HeaderLogoTheme copyWith({String? asset, Color? monochrome}) =>
      HeaderLogoTheme(
        asset: asset ?? this.asset,
        monochrome: monochrome ?? this.monochrome,
      );

  @override
  HeaderLogoTheme lerp(covariant HeaderLogoTheme? other, double t) =>
      other == null || t < .5 ? this : other;
}

class HeaderLogo extends StatelessWidget {
  const HeaderLogo({super.key});
  static const size = Size(41.6, 29.25);

  @override
  Widget build(BuildContext context) {
    final branding = Theme.of(context).extension<HeaderLogoTheme>()!;
    return Semantics(
      label: 'Romanza',
      image: true,
      child: SizedBox.fromSize(
        size: size,
        child: SvgPicture.asset(
          branding.asset,
          fit: BoxFit.contain,
          excludeFromSemantics: true,
          colorFilter: branding.monochrome == null
              ? null
              : ColorFilter.mode(branding.monochrome!, BlendMode.srcIn),
        ),
      ),
    );
  }
}
