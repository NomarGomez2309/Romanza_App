# Plan

1. Entrega visual: tema compartido, fuentes locales, Hoy vacío, navegación,
   preferencias locales y estados vacíos de Planes/Recuerdos implementados.
2. Validar en Android e iOS reales; revisión con lector de pantalla y recursos
   vectoriales finales. Custom sigue pendiente.
3. Identidad y vínculo para dos personas: contratos, flujos, reglas y pruebas.
4. Nota y planes; después recuerdos y publicación de instantáneas, con estados,
   permisos y persistencia verificables. Diseñar cada detalle antes de construirlo.
5. Validar sincronización, desconexión, reintentos y privacidad antes de publicar.

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
