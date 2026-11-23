# Fechas importantes — revisión UI

Fecha: 22 de noviembre de 2026. Base: `31557699` (Recuerdos integrado).

## Comprobaciones

- `flutter analyze --no-pub`: sin incidencias.
- `flutter test --no-pub`: **241 pruebas aprobadas**.
- Archivo específico: 41 pruebas, incluidas 18 composiciones (320/390/412,
  tres temas, texto 100/200%), orden cronológico, desempate, días naturales,
  cambio de año, año bisiesto, valores UTC, límites ayer/hoy/mañana/+7/+8,
  actualización de entradas, lista vacía y acción de Planes. También pulsación y
  cancelación con/sin reducir movimiento, y 12 composiciones del widget visual
  en cuadrados 160/180, tres temas y texto 100/200%.
- Modo de captura: **49 pruebas aprobadas** (41 + 8 capturas).
- `git diff --check`: sin incidencias.

Se inspeccionaron las dos comparativas de Flutter: jerarquía de la tarjeta,
separación de Instantáneas, tipografía, radios, tres paletas, estados y vista del
widget. Los títulos largos y el texto 200% no desbordan en los anchos comprobados.

## Capturas

- [Tres temas y propuesta de widget](evidence/important-date/themes-and-home-widget.png)
- [Grilla neutra y estados +7/mañana/hoy](evidence/important-date/grid-states.png)
- [Default 390](evidence/important-date/Default-390.png)
- [Default 412](evidence/important-date/Default-412.png)
- [Forest 390](evidence/important-date/Forest-390.png)
- [Forest 412](evidence/important-date/Forest-412.png)
- [Neo 390](evidence/important-date/Neo-390.png)
- [Neo 412](evidence/important-date/Neo-412.png)

Referencias lógicas: 390×844 y 412×924; Flutter añade las áreas seguras. Las
capturas no certifican ejecución nativa en un Pixel o iPhone físico.

## Límites

La ocasión «Nuestro aniversario» es un fixture de prueba. La app no supone que
existe una pareja vinculada ni publica ese dato. La entrada de ocasiones reales
sigue pendiente de su servicio y de la UI para crearlas.

La tarjeta está integrada en Flutter y recibe eventos explícitos. El widget de
pantalla de inicio es una especificación visual: no existe aún un proveedor
Android ni una extensión WidgetKit, ni se ha instalado en un dispositivo. El texto
ampliado se comprobó en el dashboard y la previsualización Flutter; el widget
nativo tendrá su propia revisión de tamaños, tipografía y actualización diaria.

[Diseño, lógica y próximos pasos](../modules/important-dates.md)

Revisión visual: widget con día.mes grande y mes en segunda línea, iconos
Lucide corazón/calendario y respuesta sutil. Entrada 260 ms, escala 0.985 y giro
-2.9° al pulsar; reducir movimiento elimina las transformaciones animadas.
