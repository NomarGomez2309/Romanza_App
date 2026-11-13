import 'package:flutter/material.dart';
import '../../design_system/romanza_icon.dart';

enum CameraGlyph { close, flashOn, flashOff, flip }

class CameraControlIcon extends StatelessWidget {
  const CameraControlIcon(this.glyph, {super.key, this.enabled = true});
  final CameraGlyph glyph;
  final bool enabled;
  @override
  Widget build(BuildContext context) => RomanzaIcon(
    switch (glyph) {
      CameraGlyph.close => RomanzaSymbol.x,
      CameraGlyph.flashOn => RomanzaSymbol.zap,
      CameraGlyph.flashOff => RomanzaSymbol.zapOff,
      CameraGlyph.flip => RomanzaSymbol.switchCamera,
    },
    size: glyph == CameraGlyph.close ? 22 : 28,
    color:
        (IconTheme.of(context).color ?? Theme.of(context).colorScheme.onSurface)
            .withValues(alpha: enabled ? 1 : .38),
  );
}
