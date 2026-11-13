import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum RomanzaSymbol {
  arrowLeft('assets/icons/lucide/arrow-left.svg'),
  calendarDays('assets/icons/lucide/calendar-days.svg'),
  camera('assets/icons/lucide/camera.svg'),
  check('assets/icons/lucide/check.svg'),
  fileText('assets/icons/lucide/file-text.svg'),
  globe('assets/icons/lucide/globe.svg'),
  heart('assets/icons/lucide/heart.svg'),
  house('assets/icons/lucide/house.svg'),
  images('assets/icons/lucide/images.svg'),
  link('assets/icons/lucide/link.svg'),
  logOut('assets/icons/lucide/log-out.svg'),
  mail('assets/icons/lucide/mail.svg'),
  palette('assets/icons/lucide/palette.svg'),
  plus('assets/icons/lucide/plus.svg'),
  refreshCw('assets/icons/lucide/refresh-cw.svg'),
  rotateCcw('assets/icons/lucide/rotate-ccw.svg'),
  send('assets/icons/lucide/send.svg'),
  slidersHorizontal('assets/icons/lucide/sliders-horizontal.svg'),
  switchCamera('assets/icons/lucide/switch-camera.svg'),
  trash('assets/icons/lucide/trash.svg'),
  userRound('assets/icons/lucide/user-round.svg'),
  x('assets/icons/lucide/x.svg'),
  zapOff('assets/icons/lucide/zap-off.svg'),
  zap('assets/icons/lucide/zap.svg'),
  romanzaHoy('assets/icons/romanza/romanza-hoy.svg'),
  romanzaNota('assets/icons/romanza/romanza-nota.svg'),
  romanzaRecuerdos('assets/icons/romanza/romanza-recuerdos.svg'),
  romanzaVinculo('assets/icons/romanza/romanza-vinculo.svg');

  const RomanzaSymbol(this.asset);
  final String asset;
}

/// Local 24-unit artwork; only directional arrows may be mirrored.
class RomanzaIcon extends StatelessWidget {
  const RomanzaIcon(
    this.symbol, {
    super.key,
    this.size = 24,
    this.color,
    this.semanticLabel,
    this.forward = false,
  });
  final RomanzaSymbol symbol;
  final double size;
  final Color? color;
  final String? semanticLabel;
  final bool forward;
  @override
  Widget build(BuildContext context) {
    assert(!forward || symbol == RomanzaSymbol.arrowLeft);
    final icon = SvgPicture.asset(
      symbol.asset,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(
        color ??
            IconTheme.of(context).color ??
            Theme.of(context).colorScheme.onSurface,
        BlendMode.srcIn,
      ),
      semanticsLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
    );
    return Center(
      widthFactor: 1,
      heightFactor: 1,
      child: SizedBox.square(
        dimension: size,
        child: forward ? Transform.flip(flipX: true, child: icon) : icon,
      ),
    );
  }
}

bool _licensesRegistered = false;
void registerRomanzaIconLicenses() {
  if (_licensesRegistered) return;
  _licensesRegistered = true;
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks([
      'Lucide / Romanza iconography',
    ], await rootBundle.loadString('assets/icons/LICENSE-LUCIDE.txt'));
  });
}
