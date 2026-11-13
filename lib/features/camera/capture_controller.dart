import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'camera_flash.dart';
import 'square_photo.dart';
import 'draft_repository.dart';

class CaptureController extends ChangeNotifier {
  CaptureController(this.repository);
  final DraftRepository repository;
  final flash = CameraFlash();
  bool flashEnabled = false, hardwareFlash = false, screenFlash = false;
  CameraDescription? _lens;
  bool get isFront =>
      camera?.description.lensDirection == CameraLensDirection.front;
  bool get canFlash =>
      ready &&
      (isFront
          ? defaultTargetPlatform == TargetPlatform.android
          : hardwareFlash);
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
          ? 'Permite el acceso a la cámara en Ajustes del teléfono → Aplicaciones → Romanza → Permisos. Después vuelve a intentarlo.'
          : 'No pudimos usar la cámara. Puedes reintentar o volver.';
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
      lens ?? _lens ?? cameras.first,
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
      _lens = next.description;
      hardwareFlash = await flash.hasHardware(next.description.name);
      flashEnabled = false;
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
  void toggleFlash() {
    if (busy || !canFlash) return;
    flashEnabled = !flashEnabled;
    emit();
  }

  Future<void> capture() => run(() async {
    if (!ready) return;
    final active = camera!;
    final front = isFront;
    await active.setFlashMode(
      flashEnabled && !front ? FlashMode.always : FlashMode.off,
    );
    Future<XFile> shoot() async {
      if (disposed || !_foreground || camera != active) {
        throw CameraException('Interrupted', 'Capture interrupted');
      }
      return active.takePicture();
    }

    final photo = front && flashEnabled
        ? await flash.illuminate(
            shoot: shoot,
            show: (visible) async {
              screenFlash = visible;
              emit();
              if (visible && !disposed) {
                await WidgetsBinding.instance.endOfFrame;
              }
            },
          )
        : await shoot();
    File? square;
    try {
      square = await prepareSquarePhoto(photo.path, mirror: front);
      draft = await repository.importPhoto(square.path);
      reviewing = true;
    } finally {
      for (final temporary in [?square, File(photo.path)]) {
        try {
          if (await temporary.exists()) {
            await temporary.delete();
          }
        } on FileSystemException {
          /* A cache cleanup failure must not undo a saved draft. */
        }
      }
    }
    await suspend();
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
  Future<void> discard({bool reopen = true}) => run(() async {
    await repository.delete();
    draft = null;
    reviewing = false;
    _foreground = true;
    if (reopen) await _open();
  });
  Future<void> suspend() async {
    _foreground = false;
    ++_generation;
    screenFlash = false;
    await flash.reset();
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
    unawaited(flash.reset());
    disposed = true;
    ++_generation;
    camera?.dispose();
    super.dispose();
  }
}
