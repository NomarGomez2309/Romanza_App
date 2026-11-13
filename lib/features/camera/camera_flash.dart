import 'package:flutter/services.dart';

class CameraFlash {
  static const channel = MethodChannel('romanza/camera_flash');
  Future<bool> hasHardware(String cameraId) async {
    try {
      return await channel.invokeMethod<bool>('hasFlash', {
            'cameraId': cameraId,
          }) ??
          false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Brightness belongs to this window only. Native onPause/onDestroy also
  /// restore it if Flutter is interrupted while the shutter is running.
  Future<T> illuminate<T>({
    required Future<T> Function() shoot,
    required Future<void> Function(bool) show,
  }) async {
    try {
      await channel.invokeMethod<void>('beginScreenFlash');
      await show(true);
      // Allow the white frame and camera auto-exposure to settle before capture.
      await Future<void>.delayed(const Duration(milliseconds: 250));
      return await shoot();
    } finally {
      try {
        await channel.invokeMethod<void>('endScreenFlash');
      } finally {
        await show(false);
      }
    }
  }

  Future<void> reset() async {
    try {
      await channel.invokeMethod<void>('endScreenFlash');
    } on PlatformException {
      /* Native activity also restores on pause. */
    } on MissingPluginException {
      /* Platform without this adapter. */
    }
  }
}
