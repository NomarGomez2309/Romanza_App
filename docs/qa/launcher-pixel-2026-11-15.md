# Icono y nombre de instalación — validación Pixel 9

Fecha de cierre: 15/11/2026. Base revisada: Romanza/Dart, commit 1ce2ef8f. Continuación en codex/launcher-pixel-validation. El usuario ya había guardado en ese commit la implementación del encabezado y del launcher; esta revisión no la sustituye ni reinicia Main.

## Implementación revisada

- android/app/src/main/AndroidManifest.xml: etiqueta Romanza, icon y roundIcon apuntan a ic_launcher. Sin cambios de applicationId.
- android/app/src/main/res: mipmaps por densidad, foreground/monochrome, XML adaptativo y color de fondo.
- ios/Runner/Info.plist: CFBundleDisplayName Romanza; CFBundleName interno y bundle identifier conservados.
- ios/Runner/Assets.xcassets/AppIcon.appiconset: catálogo generado sin transparencia.
- assets/launcher: SVG oficial aprobado Default (R #9FA0FF, corazón #FF7171), PNG fuente y fondo crema #FFF3E3. No depende de la paleta interior.
- flutter_launcher_icons.yaml, pubspec.yaml/pubspec.lock y tools/branding: generación reproducible y validación de recursos. flutter_launcher_icons 0.14.4.

No se encontraron AGENTS.md en el proyecto ni en las carpetas padre revisadas. No existen flavors Android ni overrides de nombre en debug/profile. No se encontraron overrides iOS de CFBundleDisplayName. Se conservan Firebase, splash, identificadores, paquete Dart y textos interiores.

## Resultados

- flutter devices y adb devices: Pixel 9 único teléfono, serial 53150DLAQ0024L, Android 17/API 37.
- flutter analyze --no-pub: sin incidencias.
- flutter build apk --debug --no-pub: correcto. Advertencia del entorno sobre versiones del XML de Android SDK; no impide compilar.
- adb install -r: Success; actualización sobre la instalación existente, sin desinstalar ni borrar datos.
- SHA-256 del archivo de preferencias antes y después de la actualización y de las pruebas: 8bb9450dd23be48f33a778acf0245a95a96c2918fdac6e9d7469e8051073a49d. No se modificaron preferencias de Romanza.
- Android: foreground y monochrome tienen radio visible máximo 30.88dp, inferior al radio seguro 33dp. Validado mediante tools/branding/validate_launcher.dart.
- iOS: 25 entradas del catálogo con dimensiones correctas y sin canal alfa. Configurado, no compilado ni probado en iPhone desde Windows.

## Prueba física del launcher

El teléfono empezó bloqueado; se continuó solo después de que el usuario lo desbloqueara. Se verificó Romanza en el listado de aplicaciones y se añadió su acceso a Inicio mediante Add to home screen. El acceso se deja disponible para el usuario.

El estilo inicial del Pixel era Minimal, Circle. Se comprobó la variante temática, se cambió temporalmente a Default para comprobar el símbolo lavanda/coral sobre crema, y después se restauró Minimal. La máscara circular no recorta el símbolo. La variante temática recibe los colores del Pixel, no los temas Default/Forest/Neo/Custom de Romanza.

Se abrió la app desde su icono; apareció Hoy, contigo y la navegación existente. El proceso seguía activo; no hubo entradas de Romanza/FATAL EXCEPTION en el buffer de cierres consultado. Esto no certifica la ausencia de errores en funciones fuera de este encargo. UiAutomator tuvo respuestas transitorias sin nodo raíz al lanzar la app; repetir la lectura tras estabilizarse confirmó el contenido, sin un cierre de la app.

Capturas recortadas al icono y nombre, sin incluir ventanas de otras aplicaciones:

- [Inicio normal](evidence/launcher/home-normal.png)
- [Inicio temático restaurado](evidence/launcher/home-themed.png)
- [Listado normal](evidence/launcher/drawer-normal.png)
- [Listado temático](evidence/launcher/drawer.png)

Logs completos locales: build/launcher-validation/{assets-final,analyze-final,build-final,tests-final}.log. Capturas completas de depuración permanecen ignoradas por Git.

## Regeneración y entrega

Ver [instrucciones y fuente](../../assets/launcher/README.md). APK de prueba: build/app/outputs/flutter-apk/app-debug.apk. Instalado únicamente como actualización debug en el Pixel; no es una publicación en tiendas. iOS queda pendiente de compilación, firma e instalación en macOS/Xcode y un dispositivo Apple.

Cierre de regresión: flutter test completó 79 pruebas aprobadas el 15/11/2026.
