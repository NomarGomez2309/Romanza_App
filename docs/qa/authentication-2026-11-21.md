# Autenticación — 21 de noviembre de 2026

## Entrega

La entrada Flutter utiliza Firebase Authentication mediante un repositorio inyectable y un controlador central de sesión. Incluye bienvenida, Google, correo y contraseña, registro, recuperación, verificación y cierre de sesión. Las contraseñas se conservan exactamente como se escriben; solo se normaliza el espacio exterior del correo.

El dashboard requiere correo verificado y consulta/creación satisfactoria del perfil propio. Un cambio de UID o cierre de sesión destruye las rutas privadas del navegador. La pérdida de conexión no se interpreta como cierre de sesión. El SDK conserva la sesión nativa; su restauración física todavía no está comprobada.

Los perfiles nuevos no inventan nombre, pareja, consentimiento ni edad. Los existentes no se sobrescriben. No se activaron publicaciones compartidas ni invitaciones.

Los documentos en `assets/legal/` son borradores accesibles desde bienvenida y Configuración. Incorporan Nomar Gomez, Nueva York, EE. UU., y romanza@gmail.com. No registran aceptación. Edad mínima definida: 18; su comprobación, dirección postal, países admitidos, conservación y procedimientos de eliminación quedan pendientes para el onboarding y lanzamiento.

## Firebase comprobado

- Proyecto real: `romanza-app`. Identificadores nativos conservados.
- Google y correo habilitados. Huellas de depuración Android coinciden con las registradas.
- Firestore Standard, base predeterminada en `us-east4`.
- Registro e inicio de sesión reales mediante REST con una cuenta desechable: mismo UID. Cuenta eliminada al terminar. No comprueba Google nativo ni entrega de correo.
- Las reglas publicadas diferían de las locales. Se conservaron íntegramente `accountProfiles` y `usernames`; se añadió `users/{uid}` privado para su titular verificado, con lista de campos y fechas del servidor. Parejas y publicaciones compartidas siguen denegadas.
- Publicación confirmada por lectura de la versión activa: `projects/romanza-app/rulesets/f5e0685d-d5b2-427c-bb10-4e4e823dc895`.
- Versión anterior para restauración administrativa: `projects/romanza-app/rulesets/6b26ff4a-21e9-4607-88be-0d6cba5f44fc`.

## Validación

- Pruebas de sesión y widgets: restauración, correo pendiente, envío duplicado, contraseña sin recortar, reintento de perfil, cuentas deshabilitadas/eliminadas, mensajes de recuperación y retirada de rutas privadas.
- Formularios a 390 × 844 y 412 × 924, texto 100 % y 200 %, con insets simulados.
- Pruebas existentes de encabezado, módulos y base visual: dos expectativas obsoletas de «Preferencias» se actualizaron a «Temas»; su archivo completo pasó después.
- Reglas probadas en emulador local sin dependencias adicionales: lectura propia, denegación anónima/ajena/sin verificar, campos de privilegios y consentimiento rechazados, parejas denegadas. Se corrigió un helper faltante durante la integración y la versión final pasó.
- Análisis de archivos afectados: sin incidencias.
- APK debug compilada: `build/app/outputs/flutter-apk/app-debug.apk`. Advertencia del entorno Android sobre versiones de metadatos SDK; no impidió compilar.

## Límites

El Pixel `53150DLAQ0024L` se conectó después de compilar. Instalación con `adb install -r`: Success; apertura correcta, tema Forest conservado. El usuario eligió su cuenta y Google abrió el dashboard. Dos arranques en frío revelaron un fallo real de persistencia: `FirebearStorageCryptoHelper` no podía descifrar ni cifrar el almacenamiento de Auth. El patrón coincide con el problema reconocido en https://github.com/firebase/firebase-android-sdk/issues/8392; no se confirmó el origen histórico del archivo dañado en este teléfono.

Con autorización explícita del usuario se eliminaron únicamente los dos XML locales de Firebase Auth (`api.Store` y `api.crypto`) del proyecto, con la app detenida. No se desinstaló ni se usó borrado general. Se añadieron exclusiones de esos dos archivos en respaldos antiguos y `dataExtractionRules` para nube/transferencia. Mantener sus rutas alineadas con la clave de persistencia del proyecto si se cambia su identificador Firebase. Esta exclusión previene restauraciones incompatibles; no incorpora recuperación automática de claves dañadas en instalaciones ajenas.

Después de la reparación y selección de la misma cuenta: Inicio visible; se detuvo el proceso y se lanzó de nuevo en frío (`LaunchState: COLD`). Resultado: Inicio restaurado, bienvenida ausente, sin repetir autenticación. Configuración abrió correctamente, mostró la cuenta autenticada y mantuvo el cierre de sesión disponible. Se dejó la app en Inicio. Captura: `C:/Users/Nomar/AppData/Local/Temp/romanza-auth-20261121/romanza-auth-verified.png`. Recepción de correos e iOS siguen sin comprobar.

La aplicación Flutter está preparada e instalada en el Pixel; las reglas Firestore se publicaron. No se publicó una versión móvil en tiendas.

Esta entrega cubre autenticación. Siguen pendientes las fases de perfil editable/onboarding, aceptación de documentos aprobados, control de edad e invitaciones bilaterales. Las reglas de esta fase no constituyen una auditoría de seguridad completa y deberán revisarse antes de habilitar nuevos modelos de datos o lanzamiento público.

## Repetir las pruebas de reglas

Con el JAR de Firestore Emulator ya disponible, iniciar el proyecto de demostración `demo-romanza-auth`, puerto local 8089 y `--rules firestore.rules`; ejecutar `node --test test/firestore_auth_rules_test.mjs`. El test utiliza exclusivamente localhost y un proyecto de demostración. Nunca usar credenciales de producción en este test.
