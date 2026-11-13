# Cámara 1:1 v4

## Alcance y fuentes
LEEME.md, Camara_1x1.svg, Confirmacion_1x1.svg y grilla v4 aportados el10/11/2026.
Sustituye únicamente la cámara/revisión v2. Sin galería, archivos ni vídeo.
Se mantiene la decisión anterior: publicación compartida bloqueada hasta cuentas
y vínculo. Las capturas existentes no se borran ni se recortan retroactivamente.

## Diseño y adaptación
CameraComposition comparte geometría entre captura y confirmación. Base390×844:
margen16, cuadrado358×358, radio20, comienzo y158 con inset47. Pixel412: lado380.
Encabezado56, espacio55 en vertical; SafeArea real. Disparador74 con centro al
ancho/2; giro a la derecha y lado izquierdo vacío. X/flash arriba, sin título en
captura. Iconos vectoriales trazados desde los SVG proporcionados; colores del
tema Romanza, Fredoka/Nunito. Sin marcos de teléfono ni líneas de construcción.
Confirmación: Tu instantánea, misma foto/cuadrado, texto opcional, duración y dos
acciones Repetir/Publicar. Aviso breve de borrador local y publicación bloqueada.
Texto grande/teclado: scroll; acciones alcanzables. En horizontal se reduce el
cuadrado para conservar controles útiles. Fotografía no se estira.

## Captura y archivo
CaptureController → preparación de foto fuera del hilo UI → DraftRepository.
Se interpreta orientación EXIF, recorta el cuadrado central y guarda PNG sin
introducir compresión con pérdida. En Pixel9 probado:1080×1080. No se promete una
resolución universal: depende del dispositivo con ResolutionPreset.high.
La selfie conserva espejo de la vista previa: decisión de implementación comunicada
al usuario. La versión CameraX utilizada espeja la vista previa y no la captura;
se aplica espejo horizontal al archivo después de interpretar EXIF.
La confirmación muestra ese archivo final, que es el mismo que se conserva localmente.
Los borradores rectangulares previos conservan archivo y se muestran completos.

## Flash
Estado inicial apagado; solo apagado/encendido. La disponibilidad trasera se consulta
con CameraCharacteristics.FLASH_INFO_AVAILABLE. FlashMode.always solo durante
captura trasera; nunca torch. Cámara frontal Android: superficie blanca durante
el disparo, brillo1 de la ventana, espera250ms para iluminar/exponer y captura.
Finalmente se restaura el brillo anterior y se retira blanco, incluso ante error.
MainActivity también restaura en onPause/onDestroy. No requiere permiso para
cambiar brillo global y no modifica el ajuste global del usuario. Al cambiar lente
o reabrir captura el flash empieza apagado.

## Estados y borradores
Cámara inicializando, lista, capturando/procesando, revisión y error. Bloqueo de
doble disparo, cambio de lente y cierre mientras trabaja. Sin permiso: instrucciones
para Ajustes, Reintentar y Volver; ninguna alternativa de galería ni bucle automático.
Repetir conserva el borrador previo hasta confirmar una nueva captura válida.
X/atrás con borrador: Cancelar, Descartar o Guardar y salir. Guardar confirma foto y
texto; fallo mantiene revisión. No se inicia el plazo24h mientras sea borrador.
Se retiró image_picker y la descripción de acceso a fototeca de iOS.

## Validación y límites
Ver [informe v4](../qa/camera-v4-2026-11-10.md). Android es plataforma validada.
Flash frontal y consulta hardware usan puente Android; no se certifica flash en
iOS/web (control deshabilitado si no hay soporte). No hay subida, expiración de
servidor ni álbum compartido. Su implementación no se simula en esta entrega.
PNG prioriza conservar calidad; almacenamiento/compresión de producción quedan
por decidir. El flash de pantalla ilumina realmente, pero su alcance depende del
brillo y la distancia, sin garantía de equivalencia al flash físico.
