# Cámara y borrador privado v2

## Objetivo y fuentes
ESPECIFICACION.md v2.1, 03_Pantalla.svg. Usuario confirmó alcance local: sin cuentas,
vínculo, subida ni publicación compartida. Cámara real, galería del sistema,
revisión, repetir, texto, guardar y descartar. Un borrador activo por dispositivo.

## Componentes y adaptación
InstantCameraScreen → CaptureController → DraftRepository → LocalDraftRepository.
CameraController e ImagePicker son adaptadores nativos usados fuera de build.
Visor radio20, controles inferiores107, disparador74, iconos28/hit48. Solo galería,
disparador y giro, más X. Sin título en cámara, flash, filtros, vídeo ni micrófono.
Vista previa cover; revisión contiene imagen completa, no promete recorte idéntico.
Revisión usa scroll para teclado y texto grande; Publicar deshabilitado con motivo.

## Estados y persistencia
Inicialización, permiso, captura, revisión, guardado y error; sin porcentajes falsos.
Permiso solicitado al entrar en cámara. Denegación ofrece Galería/Volver, sin bucle.
Sin cámara o cámara ocupada: reintento. Giro depende de lentes disponibles.
Se libera al pasar a segundo plano y al revisar; se reabre al regresar al visor.
Se invalida una inicialización tardía para evitar usar una cámara ya cerrada.

Copia privada dentro del directorio de soporte, índice JSON con reemplazo mediante
rename y fecha de creación local (NO fecha de publicación). Primero se confirma la
copia nueva; después se elimina la anterior. No se borra el original de galería.
La foto se guarda al capturar/importar; texto con Guardar borrador o al cerrar.
Texto sin guardar ante terminación abrupta del proceso no se garantiza; no hay
autoguardado por pulsación. Cambiar foto conserva el borrador previo si falla.
Descartar requiere confirmación. Guardar no inicia un plazo de24h.
ImagePicker recupera resultados perdidos por destrucción de actividad al reabrir
la cámara. Captura de vídeo y múltiples borradores quedan fuera de esta entrega.

## Calidad y límites
ResolutionPreset.high, sin compresión adicional ni límites de producto inventados.
No se modifica almacenamiento remoto ni reglas Firebase. Android es el objetivo
validado; se añadieron descripciones de permiso iOS, pero no se validó en iOS/web.
Dependencias oficiales: camera0.12.0+2, image_picker1.2.4, path_provider2.1.6
resueltas para el SDK existente. No se migraron Firebase ni Google Sign-In.

## Pruebas
Repositorio en almacenamiento temporal: reinicio, texto Unicode, fallo al importar,
reemplazo, descarte y conservación del original. Ver informe QA v2 para pruebas
reales de permisos, giro, captura, galería, teclado y ciclo de vida.
