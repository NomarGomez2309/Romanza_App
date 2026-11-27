# Romanza

Base activa en Flutter y Dart. Android usa el host Flutter de `android/`.

Continuidad en Flutter confirmada por el usuario para esta entrega, sin migración.
Módulos v2: configuración inferior, preferencias con banco de paletas e idioma,
cámara/revisión y un borrador privado recuperable. Publicación y recuerdos
compartidos permanecen bloqueados hasta cuentas y vínculo. No hay sincronización.
Ver [sistema visual vigente](docs/design-system.md), [validación](docs/validation.md) y contratos de módulo.

Cámara v4 (10 noviembre): captura1:1 sin galería, confirmación con el mismo archivo
cuadrado, flash trasero de captura y frontal de pantalla en Android.
[Diseño y límites](docs/modules/camera-v4.md) · [Resultados de pruebas](docs/qa/camera-v4-2026-11-10.md).

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

## Ramas integradas y base de seguridad

`Romanza/Dart` reúne onboarding, Welcome Waves y la base de servicios segura.
El arranque habitual (`lib/main.dart`) conserva la interfaz aprobada, sus temas
y el esquema de perfiles actual. La base segura se conserva como entrada
experimental en `lib/secure_main.dart`, con configuración independiente
`firebase.secure.json` y reglas en `backend/firestore.rules`.

No son dos esquemas intercambiables: antes de activar la base segura con cuentas
existentes hay que revisar la migración de perfiles, configurar App Check,
publicar los documentos legales definitivos y validar su backend en pruebas.
La fusión de ramas no despliega servicios ni cambia los datos de Firebase.
Consulta [la integración](docs/qa/branch-integration-2026-11-21.md) y
[la base segura](docs/secure-core.md).

## Entrega visual

Hoy, navegación a Planes/Recuerdos vacíos y Usuario con paletas Default, Forest y Neo.
La paleta se guarda localmente con shared_preferences; no existe sincronización.

Vista de desarrollo sin Firebase: flutter run -t lib/visual_preview.dart -d chrome.
Esta entrada utiliza preferencias de sesión y no es el arranque de producción.
Capturas verificables: flutter test --dart-define=CAPTURE_VISUALS=true (build/visual-review).
