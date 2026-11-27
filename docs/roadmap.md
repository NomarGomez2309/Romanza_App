# Plan

## Entrega v2 y decisiones confirmadas

Configuración, preferencias con banco Custom y cámara/borrador local implementados
en Flutter. La publicación compartida queda bloqueada por decisión expresa del
usuario hasta cuentas y vínculo. Recuerdos mantiene estado vacío real.

Guardar conservará ambas vistas (instantánea hasta24h y Recuerdos permanente).
Eliminar publicación propia borrará ambas entradas y su archivo con confirmación.
Recuerdos se ordenará por publicación descendente, fecha en zona del dispositivo.
No se implementó aún esta transacción remota, autorización ni expiración de servidor.

## Estado y siguiente integración

- Temas, banco Custom local y exploración Custom Duo implementados; sincronización
  bilateral pendiente.
- Autenticación, verificación y edición de nombre con sus contratos existentes;
  vinculación y consentimiento legal versionado pendientes.
- Planes: prototipo interactivo con borradores de sesión; sin persistencia compartida.
- Recuerdos: biblioteca, filtros, colecciones y visor preparados; sin fuente remota
  conectada en HomeShell.
- Fechas importantes: tarjeta sobre Instantáneas lista para recibir datos; widget
  del teléfono únicamente visual, sin AppWidget/WidgetKit nativo.
- Cámara: captura local1:1, revisión y flash; envío privado y expiración de servidor
  pendientes. Nota todavía no publica contenido.

Validar servicios reales, desconexión, reintentos, privacidad y hardware antes de
presentar esos prototipos como funciones compartidas operativas.

## Reglas acordadas con el usuario

- Instantáneas visibles durante 24 horas desde la publicación.
- Cada persona puede guardar sus publicaciones en Recuerdos para conservarlas.
- Recuerdos es una colección privada compartida de la pareja: ambos ven lo que
  guardó el otro. No es pública para terceros.
- Solo el autor puede eliminar las fotos o vídeos que haya publicado.
- Conservar en Recuerdos evita el vencimiento de ese contenido guardado.

Estas reglas están documentadas, no implementadas en esta entrega visual.
El borrado físico de archivos vencidos, su programación y los casos de salida
/de desvinculación necesitan diseño de servidor. No confundir ocultación de
una tarjeta o botón con autorización ni con eliminación del almacenamiento.
