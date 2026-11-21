# Romanza

Aplicación Flutter/Dart para parejas. La base activa implementa autenticación,
perfil privado, decisión central de sesión y vinculación de pareja con backend.
Las pantallas de esta fase son funcionales y mínimas; el dashboard gráfico y los
módulos de fotos/planes/recuerdos todavía no están conectados.

## Desarrollo

Flutter 3.41.9, Dart 3.11.5; Android SDK/JDK 17. Backend: Node 22 y Java 21 para
los emuladores utilizados en las pruebas.

```bash
flutter pub get
flutter analyze
flutter test
npm --prefix backend ci
./backend/node_modules/.bin/firebase emulators:exec --project demo-romanza --only firestore,storage 'npm --prefix backend test'
```

Para un Pixel de desarrollo, registrar App Check en el proyecto Firebase de
pruebas y ejecutar `flutter run --dart-define=FIREBASE_APP_CHECK_DEBUG=true`.
Configurar Auth, documentos legales y desplegar el backend de pruebas según
[la guía de servicios](docs/secure-core.md). No se ejecuta ningún despliegue
remoto como parte de instalar dependencias o correr las pruebas.

El proyecto usa Firebase Core, Auth, Firestore, Functions, App Check, Google
Sign-In y apertura de documentos legales. Firebase conserva la sesión; los
permisos de pareja y la aceptación de términos se gestionan en servidor.

Los perfiles antiguos necesitan una migración revisada: esta versión los bloquea
sin borrarlos. `legacy/flutter/` permanece archivado, excluido del análisis y sin
importaciones desde el producto activo. `functions/` conserva dependencias del
prototipo; el nuevo codebase utiliza exclusivamente `backend/`.

Storage permanece cerrado hasta implementar el ciclo seguro de fotos. Las reglas
son un prototipo probado en emuladores y deben revisarse antes del lanzamiento.
No se ha probado el acceso real en Pixel ni se han cambiado servicios remotos.

La configuración de Android/iOS previa se conserva. Web tiene un appId de Android
y macOS reutiliza opciones de iOS: requieren configuración propia. Windows/Linux
no están configurados. Las dependencias de Apple deben resolverse en macOS.

[Índice documental](docs/README.md).
