# Base de servicios segura: autenticación, perfil y pareja

Implementación propuesta en `feat/secure-session-foundation`. No despliega servicios
ni modifica cuentas remotas. Sustituye el arranque vacío por pantallas funcionales
mínimas; el dashboard gráfico y sus módulos todavía no forman parte de esta entrega.

## Arquitectura y recorrido

`RomanzaApp` inicializa servicios fuera de build, con límite de 20 s y reintento.
`SessionController` escucha Firebase Auth y decide el recorrido, común a email y
Google: bienvenida → verificación → nombre → documentos legales publicados →
aceptación explícita → pareja opcional → inicio mínimo.

- Firebase conserva la sesión; no guardamos tokens manualmente.
- Los errores de red no cierran la sesión. Se admite el perfil en caché existente;
  crear uno nuevo, aceptar términos y vincular cuentas requieren conexión.
- La carga del perfil/documentos tiene aviso tras 15 s. Un resultado atrasado de
  otra cuenta no puede sustituir la sesión actual.
- «Ahora no» persiste `onboardingSkipped`; no se vuelve a exigir vinculación en
  cada arranque. Cambiar la versión legal exige nueva aceptación.
- Verificación de email con reenvío limitado en el cliente a 60 s, y actualización
  del token antes de operar. Las operaciones sensibles exigen email verificado
  también en servidor. El límite local de reenvío no sustituye cuotas de Auth.
- Contraseñas sin recortes ni transformación; confirmación al registrarse;
  recuperación oficial. Mensajes de acceso uniformes para no confirmar cuentas.
- Google nativo usa la API 7.x; Web tiene una ruta independiente con popup.
  Vincular un proveedor usa `linkWithCredential`/`linkWithPopup`, nunca combina
  perfiles por coincidencia de email.
- Firebase cierra sesión antes de intentar cerrar Google. Desvincular pareja es
  otra operación, con confirmación, sin eliminar la identidad.

## Datos y propiedad

| Ruta | Lectura | Escritura |
| --- | --- | --- |
| `users/{uid}` | Solo propietario | Cliente: nombre, tema, idioma, omitir pareja; esquema limitado |
| `users/{uid}/consents/{version}` | Solo propietario | Servidor |
| `legal/current` | Usuario autenticado | Administrador/servidor |
| `invites/{sha256}` | Solo creador verificado | Servidor |
| `couples/{id}` | Miembros verificados del vínculo activo | Servidor |
| `couples/{id}/gallery/{id}` | Miembros verificados del vínculo activo | Solo borrado de metadatos por su autor; crear/editar cerrado |
| Rutas no definidas, `rateLimits` y Storage | Cerrado desde cliente | Cerrado desde cliente |

El perfil no duplica email ni fecha de nacimiento. Firebase Auth conserva el correo.
No se ha impuesto una edad mínima sin decisión de producto y revisión legal.
Los identificadores de vínculo, invitación y aceptación son propiedad del backend.
Se valida el esquema del perfil tanto al crear como al actualizar: claves,
tipos, tamaños, timestamps y campos inmutables. La pareja recibe únicamente el
nombre compartido en su documento de vínculo, no el perfil privado completo.
Los nombres del vínculo son una instantánea de la confirmación; no hay todavía
pantalla de edición posterior ni sincronización de cambios de nombre compartidos.

## Invitaciones y concurrencia

1. `createInvite`: 32 bytes aleatorios criptográficos, token de 43 caracteres.
   Se guarda SHA-256 del token, no el token original. Caduca a los 15 minutos.
   Generar otra revoca la anterior; solo hay una invitación propia vigente.
2. El código se muestra solo al crearlo y se copia para compartir por el medio
   elegido. Esta entrega no registra enlaces universales ni abre deep links.
3. `previewInvite`: valida código y vigencia; devuelve únicamente el nombre del
   creador. La invitación no se puede descubrir con una consulta pública.
4. `requestInvite`: el invitado confirma la identidad mostrada. Se reserva para
   esa persona y no se vincula todavía ninguna cuenta.
5. El creador ve el nombre de quien solicita y confirma con `confirmInvite`.
   Una transacción valida ambos perfiles, términos y ausencia de otro vínculo;
   comprueba la evidencia privada de consentimiento de ambos, crea la pareja y actualiza ambos perfiles y la invitación de forma atómica.
6. `revokeInvite` cancela una invitación abierta/solicitada. `unlinkCouple` cierra
   el vínculo y limpia ambos perfiles en otra transacción.

Los conflictos concurrentes se resuelven en Firestore: dos invitados no reservan
el mismo código y dos confirmaciones no pueden vincular una cuenta a dos parejas.
El backend aplica un límite compartido de 20 operaciones por UID por minuto,
incluyendo búsquedas fallidas, además de App Check obligatorio en callables.
Ese límite no es un sistema global contra creación masiva de cuentas: se deben
configurar cuotas, observabilidad y alertas antes de una beta pública.
Las invitaciones expiradas se rechazan aunque sigan almacenadas. La limpieza de
registros y la política de retención deben configurarse antes de producción.

## Términos y consentimiento

Un administrador debe publicar `legal/current` con `version` (1–128 caracteres:
letras, números, punto, guion y guion bajo), `termsUrl` y `privacyUrl` HTTPS reales.
No se incluyen documentos ficticios ni se genera una aceptación automática.
`acceptTerms` verifica versión y confirmación explícita, escribe fecha del
servidor y copia las URLs a evidencia privada; repetir la llamada conserva la
fecha original. Las URLs publicadas deberían ser inmutables por versión.

La política de edad, eliminación de cuenta/datos, tratamiento de datos y todos
los textos legales finales siguen pendientes de definición/revisión. Una marca
de aceptación no certifica por sí sola cumplimiento legal ni verificación de edad.

## Preparación y despliegue, sin ejecutarlos automáticamente

1. Crear un proyecto Firebase de pruebas y una copia de seguridad antes de tocar
   el proyecto utilizado por usuarios. Activar Email/Password y Google y la
   política de contraseñas en Firebase Console. Registrar SHA de Android para
   debug/release; verificar `google-services.json` y dominios autorizados.
2. Registrar App Check para Android (Play Integrity). En depuración local usar
   `flutter run --dart-define=FIREBASE_APP_CHECK_DEBUG=true` y registrar el token
   de depuración en el proyecto de pruebas. Nunca compartirlo ni incluirlo en git.
   Release ignora ese indicador y siempre utiliza Play Integrity.
3. `cd backend` y `npm ci` con Node 22. Configurar Firebase CLI y proyecto de
   destino explícito. El codebase `secure-core` usa `backend/`, no la antigua
   carpeta `functions/`, que solo contiene dependencias archivadas.
4. Publicar los documentos legales reales desde una cuenta administradora.
5. Revisar y adaptar los datos anteriores. Los perfiles legacy son incompatibles
   y se bloquean con un mensaje; no se borran ni convierten automáticamente.
   Preparar migración administrativa con backup, ensayo y revisión de vínculos
   existentes. No restaurar `legacy/flutter` contra estas reglas.
6. Tras revisar reglas, retención, facturación y migración, desplegar manualmente:
   `firebase deploy --project ID_DE_PRUEBAS --only firestore:rules,storage,functions:secure-core`.
   Functions requiere el plan/configuración correspondiente. No se ha ejecutado.
7. Probar en Pixel con dos cuentas, los proveedores reales, verificación y
   recuperación por email, atestación App Check y una pareja nueva. Repetir
   revocación, caducidad, reconexión y cierre de sesión. Son pruebas pendientes.

Web necesita regenerar su configuración Firebase (la existente reutiliza appId de
Android), configurar OAuth/dominos y proporcionar
`--dart-define=FIREBASE_APP_CHECK_WEB_KEY=CLAVE_PUBLICA`. iOS necesita proyecto,
proveedores y CocoaPods en macOS. No se promete soporte de Windows/Linux.
No se conectó automáticamente la aplicación a emuladores para evitar cambiar
por accidente el entorno usado por el desarrollador. Las pruebas Node solo
aceptan hosts de emulador y usan proyecto ficticio `demo-romanza`.

## Medios: siguiente fase explícita

Storage queda cerrado. No se ha implementado la cámara, subida ni expiración de
24 h en esta entrega. Antes de habilitarla se necesitan validación de archivos,
propiedad, límites acordados, caducidad en lectura, limpieza física y traslado a
Recuerdos. El borrado de metadatos de `gallery` no elimina un archivo; no se debe
considerar un borrado integral de datos. Tampoco hay URLs públicas con token.
Desvincular cierra el acceso de ambas cuentas al vínculo anterior; decidir la
conservación/exportación de recuerdos después de una ruptura es un requisito
pendiente antes de habilitar ese módulo. Un archivo ya descargado o una caché
anterior no se pueden recuperar a distancia con reglas.

## Validación reproducible

```bash
flutter pub get
flutter analyze
flutter test
npm --prefix backend ci
./backend/node_modules/.bin/firebase emulators:exec --project demo-romanza --only firestore,storage 'npm --prefix backend test'
git diff --check
```

Los tests de backend ejercitan la lógica de los handlers directamente contra
Firestore emulado y las reglas mediante clientes reales del emulador. No prueban
la frontera HTTP callable, tokens reales de App Check ni proveedores de Auth.
Los tests Flutter inyectan sesión/datos; no validan un login nativo real.

He preparado reglas prototipo restrictivas, con validación de esquema y separación
de permisos. Deben revisarse y comprobarse antes de abrir la aplicación al público.

I've set up prototype Security Rules to keep the data in Firestore safe. They are designed to be secure for owner-only profiles, server-managed relationship membership and restricted content access. However, you should review and verify them before broadly sharing your app. If you'd like, I can help you harden these rules.

Referencias oficiales:
- https://firebase.google.com/docs/auth/flutter/manage-users
- https://firebase.google.com/docs/firestore/security/rules-fields
- https://firebase.google.com/docs/functions/callable
- https://firebase.google.com/docs/app-check/cloud-functions
