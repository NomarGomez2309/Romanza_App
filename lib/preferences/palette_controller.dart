import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'custom_palette.dart';
import 'preferences_store.dart';
import '../design_system/romanza_theme.dart';
import 'palette_repository.dart';

class PaletteController extends ChangeNotifier {
  PaletteController(this.repository, {this.store});
  final PaletteRepository repository;
  final PreferencesStore? store;
  List<CustomPalette> bank = [];
  String? activeCustomId;
  bool systemLanguage = true;
  CustomPalette? get custom =>
      bank.where((p) => p.id == activeCustomId).firstOrNull;
  RomanzaPalette palette = RomanzaPalette.defaultPalette;
  bool saving = false;
  String? error;
  bool _disposed = false;

  Future<void> load() async {
    try {
      palette = await repository.read();
      final raw = await store?.read();
      if (raw != null) {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        bank = (data['bank'] as List).map(CustomPalette.fromJson).toList();
        palette = RomanzaPalette.values.firstWhere(
          (p) => p.name == data['base'],
        );
        activeCustomId = data['active'] as String?;
        systemLanguage = data['systemLanguage'] as bool;
      }
      error = null;
    } catch (_) {
      error = 'No pudimos leer tu paleta. Puedes volver a elegirla.';
    }
    _emit();
  }

  Future<void> select(RomanzaPalette next) async {
    if (saving) return;
    saving = true;
    error = null;
    _emit();
    try {
      if (store == null) {
        await repository.write(next);
      } else {
        await _persist(next, bank, null, systemLanguage);
      }
      palette = next;
      activeCustomId = null;
    } catch (_) {
      error = 'No se pudo guardar la paleta. Vuelve a intentarlo.';
    } finally {
      saving = false;
      _emit();
    }
  }

  Future<void> _persist(
    RomanzaPalette base,
    List<CustomPalette> choices,
    String? active,
    bool system,
  ) async {
    await store?.write(
      jsonEncode({
        'base': base.name,
        'bank': choices.map((p) => p.toJson()).toList(),
        'active': active,
        'systemLanguage': system,
      }),
    );
  }

  Future<bool> saveCustom(CustomPalette value) async {
    if (saving) return false;
    saving = true;
    error = null;
    _emit();
    try {
      final next = [...bank.where((p) => p.id != value.id), value];
      await _persist(palette, next, value.id, systemLanguage);
      bank = next;
      activeCustomId = value.id;
      return true;
    } catch (_) {
      error = 'No se pudo guardar la paleta. Vuelve a intentarlo.';
      return false;
    } finally {
      saving = false;
      _emit();
    }
  }

  Future<void> setLanguage(bool system) async {
    if (saving) return;
    saving = true;
    error = null;
    _emit();
    try {
      await _persist(palette, bank, activeCustomId, system);
      systemLanguage = system;
    } catch (_) {
      error = 'No se pudo guardar el idioma. Vuelve a intentarlo.';
    } finally {
      saving = false;
      _emit();
    }
  }

  void _emit() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
