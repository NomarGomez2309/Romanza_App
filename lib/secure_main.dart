import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'screens/session_root.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    RomanzaApp(
      initialize: initializeFirebase,
      homeBuilder: (_) => const SessionRoot(),
    ),
  );
}

Future<void>? _startup;
Future<void> initializeFirebase() =>
    _startup ??= _initializeServices().catchError((Object error) {
      _startup = null;
      throw error;
    });
Future<void> _initializeServices() async {
  // Retrying App Check initialization must not create a duplicate Firebase app.
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  const debugAttestation = bool.fromEnvironment('FIREBASE_APP_CHECK_DEBUG');
  const webKey = String.fromEnvironment('FIREBASE_APP_CHECK_WEB_KEY');
  if (kIsWeb && webKey.isEmpty) {
    throw StateError(
      'Configura Firebase Web y su clave App Check antes de ejecutar esta plataforma.',
    );
  }
  await FirebaseAppCheck.instance.activate(
    webProvider: kIsWeb ? ReCaptchaV3Provider(webKey) : null,
    androidProvider: !kReleaseMode && debugAttestation
        ? AndroidProvider.debug
        : AndroidProvider.playIntegrity,
    appleProvider: !kReleaseMode && debugAttestation
        ? AppleProvider.debug
        : AppleProvider.appAttestWithDeviceCheckFallback,
  );
}
