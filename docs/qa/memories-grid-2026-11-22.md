# Recuerdos — verificación visual y funcional

Fecha de revisión: 22 de noviembre de 2026. Base: `2aac5121`.

## Resultado

- `flutter analyze --no-pub`: sin incidencias.
- `flutter test --no-pub`: **200 pruebas aprobadas** en la aplicación.
- El archivo de Recuerdos incluye 18 pruebas funcionales y de composición.
- Captura con `CAPTURE_MEMORIES=true`: 21 pruebas aprobadas, incluidas tres de captura.
- Regeneración de las dos referencias monocromas: 2 pruebas aprobadas tras corregir la selección del estado Años en el capturador.
- `git diff --check`: sin incidencias.

Se comprobó orden cronológico, cambio de densidad, filtros de mes/año, colecciones,
deslizamiento y miniaturas del visor, regreso a la biblioteca y error de imagen
con etiqueta accesible. Las composiciones se verificaron en anchos lógicos 390 y
412, las tres paletas y texto al 100% y 200%.

## Evidencia

- [Comparativa de cinco vistas](evidence/memories/production-grid-board.png)
- [Biblioteca 390](evidence/memories/grid-photos-390.png)
- [Biblioteca 412](evidence/memories/grid-photos-412.png)
- [Default](evidence/memories/Default-photos.png)
- [Colecciones Default](evidence/memories/Default-collections.png)
- [Forest](evidence/memories/Forest-photos.png)
- [Neo](evidence/memories/Neo-photos.png)

La carpeta contiene además las referencias individuales Meses, Años, Colecciones
y Visor en ambos anchos. Todas son capturas del árbol real de widgets Flutter.
Las imágenes grises son fixtures locales de prueba; no representan datos de usuarios.

## Límites

No se realizaron pruebas en un Pixel físico ni en iOS nativo. Estas comprobaciones
son de widgets y renderizado en el entorno de desarrollo. La biblioteca real
continúa vacía hasta conectar registros publicados y autorizados. No se modifican
servicios, reglas, subida, eliminación ni almacenamiento de datos personales.

[Especificación y medidas](../modules/memories-grid.md)
