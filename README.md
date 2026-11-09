# Romanza

Base activa en Flutter y Dart. Android usa el host Flutter de `android/`.

Continuidad en Flutter confirmada por el usuario para esta entrega, sin migración.
Módulos v2: configuración inferior, preferencias con banco de paletas e idioma,
cámara/galería/revisión y un borrador privado recuperable. Publicación y recuerdos
compartidos permanecen bloqueados hasta cuentas y vínculo. No hay sincronización.
Ver [validación v2](docs/qa/modules-v2-2026-11-08.md) y contratos de módulo.

## Ejecutar

Requiere Flutter (validación con 3.41.9 y Dart 3.11.5) y Android SDK/JDK 17.

```powershell
flutter pub get
flutter run
flutter analyze
flutter test
.\android\gradlew.bat -p android :app:testDebugUnitTest :app:lintDebug :app:assembleDebug
```

`lib/main.dart` conecta Firebase y arranca `RomanzaApp`. La pantalla inicial
muestra progreso, error con reintento y después la pantalla Hoy con estados vacíos.
Inicializar el SDK no verifica acceso remoto, reglas, cuentas ni sincronización.

Dependencias directas: Flutter, Firebase Core, Authentication, Firestore y Google
Sign-In (reservado para el futuro acceso con Google). No hay login implementado.
Se conservan las versiones Firebase existentes para no mezclar la limpieza con
una migración mayor. `pubspec.lock` fija las versiones resueltas.

La configuración Firebase existente se conserva. Android e iOS tienen opciones;
web contiene un appId de Android y macOS reutiliza las opciones de iOS: requieren
configuración específica antes de usarse. Windows y Linux no están configurados.
Consulta la [guía oficial de FlutterFire](https://firebase.google.com/docs/flutter/setup)
para configurar las plataformas necesarias con `flutterfire configure`.
No se han modificado servicios remotos ni desplegado reglas.

El prototipo anterior está en `legacy/flutter/`, excluido del análisis y del
arranque. Sus dependencias originales están en `pubspec.yaml.reference`.
Las fuentes Fredoka/Nunito y sus licencias se empaquetan localmente. Las imágenes históricas se conservan sin empaquetar.

[Índice documental](docs/README.md).

## Entrega visual

Hoy, navegación a Planes/Recuerdos vacíos y Usuario con paletas Default, Forest y Neo.
La paleta se guarda localmente con shared_preferences; no existe sincronización.

Vista de desarrollo sin Firebase: flutter run -t lib/visual_preview.dart -d chrome.
Esta entrada utiliza preferencias de sesión y no es el arranque de producción.
Capturas verificables: flutter test --dart-define=CAPTURE_VISUALS=true (build/visual-review).
