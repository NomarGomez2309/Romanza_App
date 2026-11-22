# Validación de navegación flotante

Base: `96b740bd005ec80d44ad28d0b3a29b466399b917` (`Romanza/Dart`).

- Flutter analyze: sin incidencias.
- Suite completa Flutter:182 pruebas aprobadas.
- Nueva suite de navegación:23 pruebas funcionales aprobadas.
- Comparativa visual opcional:1 render aprobado.
- Suite de iconografía:11 pruebas aprobadas, incluidas semántica y dimensiones
  estables al cambiar de selección.
- git diff --check: correcto.

Se comprobaron320,390 y412 de ancho, tres paletas, texto100%/200%, las tres
selecciones y áreas táctiles mínimas. Se verificó la trayectoria intermedia del
selector y su continuidad al redirigirlo; compresión y elevación del icono en
límites renderizados; reducir movimiento sin transformaciones; alto contraste
sin filtro; orden RTL; y último contenido de Planes accesible sobre la barra.

Las comprobaciones antiguas de píldoras individuales ahora miden los nuevos
botones de navegación, con mínimo48 y altura adaptable a etiquetas envueltas.
Conservan la comprobación de etiquetas seleccionadas y acciones semánticas.

## Evidencia real de Flutter

- [Comparación de paletas](evidence/navigation/palette-comparison.png)
- [Inicio Default](evidence/navigation/Default-tab-0.png)
- [Planes Default](evidence/navigation/Default-tab-1.png)
- [Recuerdos Default](evidence/navigation/Default-tab-2.png)
- [Planes Forest](evidence/navigation/Forest-tab-1.png)
- [Planes Neo](evidence/navigation/Neo-tab-1.png)
- [Comienzo de transición](evidence/navigation/Default-motion-start.png)
- [Transición intermedia](evidence/navigation/Default-motion-middle.png)
- [Pulsación mantenida](evidence/navigation/Default-pressed.png)
- [Vídeo del selector](evidence/navigation/selector-motion.mp4):1.62 segundos,
  780×1688, H.264;54 fotogramas reales, muestreados cada30ms.

El vídeo se codificó con FFmpeg a partir de las capturas de Flutter; no es una
animación generativa. Los planes son fixtures de prueba, no datos de una cuenta.
No se instaló en Pixel ni se midieron tiempos de frame en GPU móvil. La prueba
funcional de animación no constituye una garantía de60fps en un dispositivo.

## Revisión de relleno

Variantes de Hoy, Planes y Recuerdos con detalles en negativo. La nueva prueba
rasteriza el icono del calendario y cuenta píxeles de tinta para comprobar que
aumenta su superficie al mantener pulsado, vuelve al trazo al cancelar y conserva
el relleno al seleccionar; vuelve al trazo al cambiar de pestaña. Se actualizan
las imágenes y el clip desde los widgets reales.
