import 'package:flutter/foundation.dart';
import '../design_system/romanza_theme.dart';
import 'palette_repository.dart';

class PaletteController extends ChangeNotifier {
  PaletteController(this.repository);
  final PaletteRepository repository;
  RomanzaPalette palette = RomanzaPalette.defaultPalette;
  bool saving = false;
  String? error;
  bool _disposed = false;

  Future<void> load() async {
    try {
      palette = await repository.read();
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
      await repository.write(next);
      palette = next;
    } catch (_) {
      error = 'No se pudo guardar la paleta. Vuelve a intentarlo.';
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
