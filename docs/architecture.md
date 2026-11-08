# Arquitectura

Producto activo: Flutter y Dart. Android es el host Flutter; el prototipo
anterior permanece en legacy/flutter, fuera del análisis y del arranque.

- lib/main.dart: inicialización Firebase y repositorio local de preferencias.
- lib/app.dart: carga/error/reintento de arranque y composición del tema.
- lib/design_system: colores, tipografía, dimensiones y componentes compartidos.
- lib/features/home_shell.dart: navegación Hoy/Planes/Recuerdos.
- lib/features/today: pantalla Hoy sin datos de negocio inventados.
- lib/preferences: controlador de estado → contrato PaletteRepository →
  LocalPaletteRepository con SharedPreferencesAsync. Escritura confirmada antes
  de cambiar paleta; un error conserva la elección anterior y permite reintentar.
- lib/visual_preview.dart: entrada explícita de desarrollo sin Firebase ni cuentas.
  Usa preferencias de sesión; no sustituye el punto de entrada de producción.

No hay I/O en build. La UI consume el controlador; las preferencias se leen una
vez al iniciar y se escriben al seleccionar. Clave local romanza.palette.v1;
valores desconocidos usan Default. Solo persiste la paleta, no fotos ni usuarios.
La lectura fallida no impide abrir Hoy y se informa en Preferencias.

Se mantiene Firebase Core/Auth/Firestore y Google Sign-In de la base. Solo se
agrega shared_preferences, necesario para la elección local de paleta. Fuentes
empaquetadas con OFL; sin google_fonts ni descarga de fuentes en ejecución.

No hay autenticación, vínculo ni sincronización implementados. Las pantallas
Planes y Recuerdos son estados vacíos. No se efectúan escrituras remotas ni se
modifican reglas de Firebase. Las futuras funciones usarán presentación →
controlador → contrato de repositorio → servicio/almacenamiento.
