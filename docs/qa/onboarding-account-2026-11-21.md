# Onboarding y cuenta — validación del 21/11/2026

Base: `53b9743f`, rama objetivo `Romanza/Dart`.

- Flutter 3.41.9 / Dart 3.11.5 en Linux.
- `flutter analyze --no-pub`: sin incidencias.
- `flutter test --no-pub --reporter expanded`: 134 pruebas aprobadas.
- Pruebas nuevas de diseño/flujo: 17 aprobadas, incluidas en el total anterior.
- `git diff --check`: sin errores.
- Se conservan pruebas previas de acceso, navegación privada, encabezado, panel,
  paletas/Custom Duo, cámara y recuerdos; no se sustituyeron por pruebas visuales.

Se comprueban 390×844 y 412×924, Default/Forest/Neo y texto100/200%. Se verifican
nombre vacío, guardado/error/reintento, preservación del borrador, guardado tardío
tras cambio de UID, cierre de sesión con Cuenta abierta y teclado elevado.
Las lecturas/escrituras de nombre se prueban mediante un repositorio falso, no
contra Firebase real. La operación real utiliza el campo `users/{uid}.name` y
las reglas ya presentes, sin modificaciones ni despliegue de reglas.

Capturas en `evidence/onboarding-v1/`, con fuentes e iconos locales cargados por
Flutter. Los fixtures de nombre/email son datos de prueba. No son fotografías
de personas ni capturas de una instalación física. Se revisaron visualmente la
bienvenida, el registro y la cuenta. No se certifica TalkBack/VoiceOver; las
pruebas de layout con texto grande no sustituyen una revisión manual de accesibilidad.

Pendiente: probar en Pixel con Firebase de desarrollo la verificación y el
registro por correo, el nombre de una cuenta nueva y su restauración tras cerrar
la app, la edición desde Configuración y los errores de conexión. No se compiló
APK ni se instaló en un dispositivo en esta entrega.

No se desplegó Firebase ni se publicó una versión móvil. El resto de pendientes
(edad, consentimiento sobre textos finales, parejas y publicación) conserva el
alcance del commit base. Detalles: [módulo](../modules/onboarding-account.md).
