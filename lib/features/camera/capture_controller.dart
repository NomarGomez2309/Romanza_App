import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'draft_repository.dart';

class CaptureController extends ChangeNotifier {
  CaptureController(this.repository);
  final DraftRepository repository;
  CameraController? camera;
  List<CameraDescription> cameras = [];
  PhotoDraft? draft;
  bool busy = false, disposed = false, reviewing = false;
  String? error;
  int _generation = 0;
  bool _foreground = true;
  bool _resumePending = false;
  bool _permissionDenied = false;
  Future<void> _release = Future<void>.value();
  bool get ready => camera?.value.isInitialized == true;
  void emit() {
    if (!disposed) notifyListeners();
  }

  Future<void> run(Future<void> Function() operation) async {
    if (busy || disposed) return;
    busy = true;
    error = null;
    emit();
    try {
      await operation();
    } on CameraException catch (e) {
      _permissionDenied =
          e.code.contains('AccessDenied') || e.code.contains('Restricted');
      error = _permissionDenied
          ? 'No tenemos permiso para usar la cámara. Puedes elegir una foto de Galería o volver.'
          : 'No pudimos usar la cámara. Puedes reintentar o abrir Galería.';
    } catch (_) {
      error =
          'No pudimos completar la acción. Tu borrador anterior se conserva. Vuelve a intentarlo.';
    } finally {
      busy = false;
      emit();
      if (_resumePending &&
          _foreground &&
          !reviewing &&
          !ready &&
          error == null &&
          !disposed) {
        _resumePending = false;
        unawaited(retryCamera());
      }
    }
  }

  Future<void> start() => run(() async {
    draft = await repository.read();
    reviewing = draft != null;
    if (defaultTargetPlatform == TargetPlatform.android) {
      final lost = await ImagePicker().retrieveLostData();
      if (lost.exception != null) throw lost.exception!;
      if (lost.files?.isNotEmpty == true) {
        draft = await repository.importPhoto(lost.files!.first.path);
        reviewing = true;
      }
    }
    if (!reviewing) await _open();
  });
  Future<void> _open([CameraDescription? lens]) async {
    final generation = ++_generation;
    final previous = camera;
    camera = null;
    emit();
    await previous?.dispose();
    await _release;
    if (cameras.isEmpty) cameras = await availableCameras();
    if (cameras.isEmpty) throw CameraException('Unavailable', 'No camera');
    if (disposed || !_foreground || generation != _generation) return;
    final next = CameraController(
      lens ?? cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );
    try {
      await next.initialize();
      await next.setFlashMode(FlashMode.off);
      if (disposed || !_foreground || generation != _generation) {
        await next.dispose();
        return;
      }
      camera = next;
      _permissionDenied = false;
      emit();
    } catch (_) {
      await next.dispose();
      rethrow;
    }
  }

  Future<void> retryCamera() => run(() => _open());
  Future<void> flip() => run(() async {
    final current = camera?.description;
    final other = cameras
        .where((c) => c.lensDirection != current?.lensDirection)
        .firstOrNull;
    if (other != null) await _open(other);
  });
  bool get canFlip => cameras.map((c) => c.lensDirection).toSet().length > 1;
  Future<void> capture() => run(() async {
    if (!ready) return;
    final photo = await camera!.takePicture();
    draft = await repository.importPhoto(photo.path);
    reviewing = true;
    await suspend();
  });
  Future<void> gallery() => run(() async {
    final photo = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (photo != null) {
      draft = await repository.importPhoto(photo.path);
      reviewing = true;
      await suspend();
    } else if (!reviewing && !ready && !_permissionDenied) {
      _foreground = true;
      await _open();
    } else if (_permissionDenied && !reviewing) {
      error =
          'No tenemos permiso para usar la cámara. Puedes elegir una foto de Galería o volver.';
    }
  });
  Future<void> repeat() => run(() async {
    reviewing = false;
    _foreground = true;
    await _open();
  });
  Future<void> saveCaption(String text) => run(() async {
    if (draft == null) return;
    final next = draft!.withCaption(text);
    await repository.save(next);
    draft = next;
  });
  Future<void> discard() => run(() async {
    await repository.delete();
    draft = null;
    reviewing = false;
    _foreground = true;
    await _open();
  });
  Future<void> suspend() async {
    _foreground = false;
    ++_generation;
    final old = camera;
    camera = null;
    emit();
    _release = _release.then((_) async {
      await old?.dispose();
    });
    await _release;
  }

  Future<void> resume() async {
    _foreground = true;
    _resumePending = busy;
    if (!reviewing && !busy && !disposed && error == null) await retryCamera();
  }

  @override
  void dispose() {
    disposed = true;
    ++_generation;
    camera?.dispose();
    super.dispose();
  }
}
