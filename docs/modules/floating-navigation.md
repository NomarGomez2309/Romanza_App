# Navegación inferior — cápsula flotante Romanza

La referencia visual aportada por el usuario inspira un contenedor único, con
relieve fino y selección continua. Se conservan Hoy, Planes y Recuerdos, sus
iconos Lucide/Romanza y la tipografía Nunito. La barra se adapta a Default,
Forest, Neo y los colores Custom existentes.

## Geometría

| Elemento | Unidades lógicas |
| --- | --- |
| Ancho máximo | 448, centrado |
| Margen horizontal | 16, además de área segura |
| Separación vertical | 8 arriba y 8 abajo, además de área segura inferior |
| Radio exterior | 36 |
| Borde exterior | 1.1, mezcla de fondo/tinta del tema |
| Separación del selector al contenedor | 6 uniforme |
| Radio del selector / zonas de interacción | 30 |
| Alto interior | Mínimo64; crece según altura de etiquetas |
| Alto de cápsula | Interior +12; normal76 |
| Iconos | 24; el activo alcanza25.92 en reposo sin reducir movimiento |
| Etiquetas | Nunito12/16, peso700 |
| Separación icono-etiqueta | 4 |
| Área táctil | Mínimo48 por destino en anchos comprobados |

Se miden las etiquetas con el escalado real del dispositivo. Cuando caben se
reparten en tres segmentos iguales; cuando necesitan más espacio se redistribuye
el ancho. Si aún falta espacio, pueden envolver y crece la altura común. No se
reduce el texto del sistema para encajarlo. La posición y el ancho del selector
se calculan a partir de esos mismos segmentos, sin coordenadas rígidas por tema.

El radio36 exterior menos el inset6 produce el radio30 interior. Todo se recorta
con la misma geometría. El contorno y la sombra permanecen estáticos mientras
se desplaza una sola superficie seleccionada.

## Superficie y contraste

Fondo del tema traslúcido, un ligero gradiente de luz y BackdropFilter sigma18,
recortado a la cápsula. Sombra exterior suave y contorno fino continuo. El
selector utiliza tintes del primario sobre el fondo, conservando texto e iconos
con tinta legible. No se importa ningún recurso gráfico de Apple.

En alto contraste se elimina el desenfoque, se hacen opacas las superficies y el
selector utiliza primary/onPrimary. El foco de teclado tiene su propio contorno.
Etiquetas y estado seleccionado forman parte de la semántica; los SVG son
imágenes decorativas dentro de cada botón etiquetado.

`HomeShell` activa extendBody para que las superficies de contenido pasen por
detrás del vidrio. `RomanzaPage` suma el inset inferior de MediaQuery a su padding
de scroll: permite subir el último elemento por encima de la barra. No se añade
una capa opaca del ancho completo de la pantalla.

## Iconos con relleno

Hoy, Planes y Recuerdos tienen variantes SVG rellenas de24 unidades. Se activa
el relleno mientras se mantiene pulsado el icono o si su pestaña está seleccionada.
Cancelar el gesto devuelve el trazo; después de seleccionar, el relleno permanece
hasta cambiar de pestaña. El color sigue el rol de contraste del tema.

Los corazones de casa/libro y los seis días del calendario se recortan en negativo
mediante fill-rule evenodd. Conservan detalle sin añadir un segundo color ni tapar
su símbolo interior. El resto de iconos de la aplicación mantiene su versión de
trazo. RomanzaIcon añade filled=false por defecto y el enum conserva sus31 símbolos.
La selección rellena también funciona con reducir movimiento y alto contraste.

## Movimiento

- Selector único:360ms, easeOutCubic. Interpolación de posición y ancho.
- Si otra pulsación cambia el destino durante la transición, se continúa desde
  la posición actual; no se salta al inicio o al destino anterior.
- Pulsación: el icono se comprime al92% con transición de100ms.
- Selección: impulso de320ms, elevación máxima3 y giro temporal de±0.06 radianes.
- Icono activo: escala108% en180ms, manteniendo fija el área táctil.
- Sin movimiento continuo en reposo ni cambios de página automáticos.

Con reducir movimiento: selector inmediato, sin compresión, elevación, giro ni
cambio de escala animado. Se conserva la diferenciación por color y posición.
El cambio de página sigue usando el IndexedStack existente; no se duplican rutas
ni se destruyen borradores al cambiar de pestaña.

## Archivos y comprobación

`lib/design_system/romanza_navigation.dart` contiene la geometría, selección e
interacciones. Se exporta desde home_shell.dart para conservar sus consumidores.
No hay nuevas dependencias, permisos, almacenamiento ni cambios de autenticación.

Pruebas en `test/navigation_motion_test.dart`:

- 320,390,412 de ancho; tres temas; texto100% y200%; todas las pestañas.
- Coincidencia de bordes del selector con la zona seleccionada y áreas mínimas.
- Trayectoria intermedia real y redirección antes de acabar la animación.
- Compresión del icono y elevación comprobadas en sus límites renderizados.
- Reducir movimiento, alto contraste sin filtro, orden RTL y último texto accesible.

Capturas reales con fixtures de pruebas en `docs/qa/evidence/navigation/`.
`selector-motion.mp4` se genera a partir de54 fotogramas renderizados por Flutter,
sin interpolación generativa, y muestra tres transiciones de selección.

```
flutter analyze --no-pub
flutter test --no-pub
flutter test --no-pub --dart-define=CAPTURE_NAVIGATION=true --dart-define=CAPTURE_NAVIGATION_VIDEO=true test/navigation_motion_test.dart
ffmpeg -y -framerate 1000/30 -i build/navigation-frames/frame-%03d.png -c:v libx264 -crf 20 -pix_fmt yuv420p -movflags +faststart docs/qa/evidence/navigation/selector-motion.mp4
```

La fluidez se comprueba funcionalmente en Flutter; falta medir tiempos de frame
y coste del filtro en un dispositivo físico. No se afirma un rendimiento de60fps
ni una instalación en Pixel a partir de estas capturas.
