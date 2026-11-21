import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Romanza currently supports Spanish; unsupported device locales fall back to it.
class SettingsLocalizations {
  const SettingsLocalizations();
  static SettingsLocalizations of(BuildContext context) =>
      Localizations.of<SettingsLocalizations>(context, SettingsLocalizations) ??
      const SettingsLocalizations();
  static const delegate = _SettingsDelegate();
  String get title => 'Configuración';
  String get account => 'Tu cuenta';
  String get themes => 'Temas';
  String get couple => 'Mi Pareja';
  String get signedOut => 'Sin sesión iniciada';
  String get noPartner => 'Sin pareja vinculada';
  String get loading => 'Cargando cuenta…';
  String get loadingPartner => 'Consultando vínculo…';
  String get error => 'No pudimos cargar la cuenta';
  String get partnerError => 'No pudimos consultar el vínculo';
  String get unnamed => 'Cuenta sin nombre';
  String linkedWith(String name) => 'Vinculado con $name';
  String destination(String key) => switch (key) {
    'Preferencias' => themes,
    'Administración de pareja' => couple,
    _ => key,
  };
}

class _SettingsDelegate extends LocalizationsDelegate<SettingsLocalizations> {
  const _SettingsDelegate();
  @override
  bool isSupported(Locale locale) => locale.languageCode == 'es';
  @override
  Future<SettingsLocalizations> load(Locale locale) =>
      SynchronousFuture(const SettingsLocalizations());
  @override
  bool shouldReload(_SettingsDelegate old) => false;
}
