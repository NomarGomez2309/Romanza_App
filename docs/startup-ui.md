# Arranque y sesión

Inicializa Firebase y App Check fuera de build. Se ejecuta una vez y comparte la
operación si hay un reintento mientras sigue pendiente. A los 20 segundos aparece
error/reintento si no termina; no se afirma que inicializar un SDK pruebe conexión
remota o permisos.

Tras éxito se construye `SessionRoot`, que decide entre acceso, verificación,
perfil, documentos/aceptación, pareja opcional e inicio mínimo. El perfil tiene
otro límite de carga de 15 s. Ver [la especificación de servicios](secure-core.md).

Material 3 estándar, margen de 24 y separación de 16. Estas pantallas permiten
probar la lógica de servicios y no sustituyen las grillas visuales aprobadas.

Pruebas: arranque pendiente/completado, error/reintento, construcción de sesión
solo después de inicializar y recuperación después de un timeout.
