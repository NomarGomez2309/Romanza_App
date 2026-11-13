# Validación de iconografía — 12/11/2026

## Resultado automatizado

- `flutter analyze --no-pub`: sin incidencias.
- `flutter test`: 53 pruebas aprobadas (42 existentes y 11 nuevas).
- `flutter build apk --debug --no-pub`: APK compilado e instalado en Pixel 9.
- 28 SVG comparados byte a byte con el paquete entregado: idénticos. Todos cargan y renderizan en pruebas.
- Matriz de navegación: 320/390/412 puntos, escalas 100/115/200 %, tres paletas, las tres opciones seleccionadas sucesivamente. Sin desbordamientos, etiquetas en una línea, controles mínimos 80 × 56, contenido principal visible y tamaño estable entre selecciones.
- Semántica comprobada: nombre único por opción, botón, selección, foco y acción. Contraste de primario/sobre primario y acento/sobre acento >= 4.5 en las tres paletas.
- Las pruebas existentes de cámara, encuadre, borradores, limpieza del flash y preferencias siguen pasando.

## Pixel 9

Android 17, 1080 × 2424 físicos, densidad 420. Instalación conservando los datos existentes.

- Hoy → Planes → Recuerdos responde y actualiza selección. A escala 115 %, Hoy y Planes miden 210 × 155 físicos (80 × aproximadamente 59 lógicos); Recuerdos amplía su anchura para acomodar el texto. Se elimina la pastilla estrecha original.
- Configuración y Preferencias abren; se comprueban Default, Forest y Neo, sus iconos y estado seleccionado. Se restaura Default, la paleta encontrada al iniciar esta revisión.
- Escala del sistema 200 %: las tres etiquetas siguen completas y la barra queda fija con contenido desplazable. Se restaura el 115 % original.
- Desde Recuerdos se abre la confirmación del borrador existente; el cierre ofrece conservarlo y Publicar permanece deshabilitado. No se toma ni descarta una foto del usuario.

## Hallazgos corregidos

1. La condición antigua eliminaba el ancho de 80 al superar escala 100 %, encogiendo Hoy al ancho de su etiqueta.
2. La medición debe incluir el estilo heredado real del texto; medir solo el estilo parcial causaba saltos de línea.
3. Durante la implementación, un Center sin heightFactor ocupaba la altura disponible en la barra. Corregido y cubierto por regresión.
4. En 320 puntos al 200 %, se requieren márgenes de 8 para conservar etiquetas completas y controles mínimos. No cambia la grilla del Pixel 9.

## Límites y evidencias

Hay una videollamada flotante activa. No se disputa su cámara: giro, captura física y flash no se vuelven a ejecutar en esta sesión. Los SVG y las pruebas de cámara pasan, pero esto no sustituye una nueva prueba física de flash. No se certifica TalkBack hablado ni iOS; se validó la semántica automatizada y Android real.

Evidencias locales ignoradas por Git: build/icon-tests-final.log, build/icon-analyze.log, build/icon-build.log y build/visual-audit/icons-*. La imagen icons-navigation.png contiene solamente la barra de Romanza, sin contenido de otras aplicaciones. Las fotos del borrador y capturas con la videollamada no se incorporan al repositorio.

El archivo de foto y el JSON del borrador conservan sus hashes SHA-256 antes y después de la revisión.
