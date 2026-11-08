import 'package:shared_preferences/shared_preferences.dart';
import '../design_system/romanza_theme.dart';

abstract interface class PaletteRepository {
  Future<RomanzaPalette> read();
  Future<void> write(RomanzaPalette palette);
}

class LocalPaletteRepository implements PaletteRepository {
  LocalPaletteRepository({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();
  final SharedPreferencesAsync _preferences;
  static const key = 'romanza.palette.v1';
  @override
  Future<RomanzaPalette> read() async {
    final name = await _preferences.getString(key);
    return RomanzaPalette.values.where((p) => p.name == name).firstOrNull ??
        RomanzaPalette.defaultPalette;
  }

  @override
  Future<void> write(RomanzaPalette palette) =>
      _preferences.setString(key, palette.name);
}

/// Used only by tests and the explicit visual preview entry point.
class MemoryPaletteRepository implements PaletteRepository {
  RomanzaPalette value = RomanzaPalette.defaultPalette;
  @override
  Future<RomanzaPalette> read() async => value;
  @override
  Future<void> write(RomanzaPalette palette) async {
    value = palette;
  }
}
