# Validación de la base Flutter

- Flutter 3.41.9 y Dart 3.11.5.
- `flutter pub get`: correcto; dependencias y registros de plugins regenerados.
- `flutter analyze`: sin incidencias.
- `flutter test`: dos pruebas aprobadas (carga/éxito y error/reintento).
- `git diff --check`: sin errores de espacios.
- Android: `:app:testDebugUnitTest :app:lintDebug :app:assembleDebug` completado correctamente. La tarea nativa de pruebas indica NO-SOURCE; las dos pruebas reales son las de Flutter. Lint conserva una advertencia previa sobre drawable-v21 redundante.

Las pruebas de interfaz inyectan la inicialización y no acceden a Firebase real.
No se han validado cuentas, permisos Firestore, sincronización ni ejecución en
un dispositivo. iOS/macOS no se han compilado desde Windows. Web necesita una
configuración Firebase propia; Windows/Linux no tienen opciones configuradas.


Se apartaron dos entradas dañadas de la caché Gradle para regenerarlas y se retiró la actividad Android del antiguo plugin OAuth. Los Podfile.lock de Apple se conservan y deben regenerarse con CocoaPods en macOS tras cambiar las dependencias.
