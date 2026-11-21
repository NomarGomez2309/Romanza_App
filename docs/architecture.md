# Arquitectura activa

Flutter/Dart con Firebase. No se importa el prototipo archivado en `legacy/`.

- `lib/main.dart`: inicialización compartida/reintentable de Firebase y App Check.
- `lib/app.dart`: carga inicial limitada a 20 s, error/reintento y construcción del flujo.
- `lib/services/auth_service.dart`: Auth, verificación, recuperación y proveedores.
- `lib/services/profile_repository.dart`: perfil privado, documentos legales y aceptación por callable.
- `lib/services/couple_repository.dart`: contrato de operaciones remotas de pareja.
- `lib/session/session_controller.dart`: resolución común de sesión y protección frente a respuestas atrasadas.
- `lib/screens/session_root.dart`: pantallas mínimas de acceso, onboarding y pareja; no es el dashboard visual definitivo.
- `backend/src/core.js`: lógica transaccional de consentimiento e invitaciones, con límites de intentos por UID.
- `backend/src/index.js`: frontera callable con Auth y App Check obligatorios.
- `firestore.rules`: perfil validado, pertenencia gestionada por servidor y acceso privado.
- `storage.rules`: denegación hasta completar la fase de medios.

Presentación, estado y operaciones externas están separados. Los servicios se
construyen después de inicializar Firebase. Auth y datos de sesión tienen
contratos inyectables para probar cambios de usuario, errores y navegación.

El backend usa el Admin SDK, por lo que valida identidad y reglas de negocio
explícitamente: las reglas de cliente no protegen por sí mismas sus escrituras.
La app no puede asignarse una pareja ni fabricar aceptación de términos.

La UI de esta fase conserva Material 3 y no pretende sustituir las grillas
aprobadas ni definir un sistema visual nuevo. Ver [alcance, límites y despliegue](secure-core.md).
