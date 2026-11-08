// Explicit development entry point: no Firebase, accounts or network content.
import 'package:flutter/material.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(RomanzaApp(initialize: () async {}));
}
