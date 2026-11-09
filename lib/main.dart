import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'preferences/palette_repository.dart';
import 'preferences/preferences_store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    RomanzaApp(
      initialize: initializeFirebase,
      paletteRepository: LocalPaletteRepository(),
      preferencesStore: LocalPreferencesStore(),
    ),
  );
}

Future<void> initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}
