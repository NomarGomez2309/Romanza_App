# Sistema visual Romanza

Fuente: Romanza_Diseno_Recursos_Medidas_v1.docx y grillas Pixel 9/iPhone 14,
aportados por el usuario. Dirección cálida, suave y juvenil; sin neobrutalismo.
Este documento distingue la especificación de la entrega y sus límites.

## Contrato para la implementación

Fredoka local: marca 700 30/36, saludo 600 34/40, sección 600 25/32,
tarjetas 500 16/20 y recuerdo 500 15/20. Nunito local: contador 15/20,
cuerpo 14/20, descripción 12/20, tiempo 12/16 y navegación 14/18.
Conservar escalado de texto y permitir crecimiento, sin reducir texto para encajar.

Default es la paleta inicial. Bases: #9FA0FF #D5E8E6 #FFF3E3 #FF7171.
Forest: #F3F6F4 #7D8D39 #5B6E2C #FF5A22.
Neo: #08CB00 #253900 #000000 #EEEEEE.
Roles derivados centralizados en RomanzaColors. Forest usa texto #111A08
sobre primario en vez de blanco: la combinación blanca original da 3,66:1. El texto secundario Forest usa #4D5E26 para cumplir 4,5:1 también sobre tarjetas; los cuatro colores base se conservan.
Custom no forma parte de esta entrega. Paleta y luminosidad no son ajustes separados.

Márgenes 16, separación entre fotos 8, ratio ancho/alto 0,86, radios 16.
Avatar 64, solapamiento 10, grupo 118×64. Botón + visual 52×44, hitbox 52×48.
Nota/plan mínimo 64; recuerdo mínimo 68. Miniatura 80×52, radio 12.
Icono 26, fondo expresivo 44. Navegación mínimo 72, pastilla 80×56.
SafeArea real, navegación fuera del scroll y ancho máximo de contenido 520
para evitar estirar fotos en ventanas grandes (decisión de esta implementación).
Las alturas crecen con accesibilidad. Ningún inset ni coordenada Y se fija por teléfono.

## Estados y recursos

El dashboard muestra ausencia real de contenido; sin fotos, días ni pareja inventados.
El selector de paleta es una preferencia local, no sincronizada. Las acciones de
contenido explican que el acceso/vínculo llegará después; no simulan guardar.
Iconos Material delineados y formas vectoriales propias como base; ilustraciones
finales pendientes. Fuentes y licencias se empaquetan, sin descarga en ejecución.
Decoraciones excluidas de semántica y gestos. Estados compartidos para carga,
error, vacío y avisos. Foco visible, controles táctiles de al menos 48.
