# Fechas importantes — dashboard y propuesta de widget

## Intención

Recordar una ocasión cercana con calma: una sola tarjeta antes de Instantáneas,
sin avisos de urgencia, parpadeos, banners apilados ni notificaciones push.
Se reutilizan Fredoka, Nunito, Lucide y los colores semánticos de Romanza.

## Comportamiento del dashboard

- `HomeShell.importantDates` y `TodayScreen.importantDates` reciben ocasiones
  explícitas mediante `ImportantDate(id, title, date)`. Por defecto la lista está vacía.
- Elegir la fecha futura o de hoy más cercana. Si varias coinciden, desempatar por id.
- Mostrar una única tarjeta desde siete días naturales antes (incluido) hasta el
  final del día del evento. Una fecha a ocho días todavía no activa la tarjeta.
- Etiquetas: «En 7 días» … «En 2 días», «Mañana», «Es hoy».
- No se muestran eventos pasados. Al desaparecer uno, la próxima fecha puede
  ocupar su lugar si también está dentro de la ventana.
- Sin fechas, ocultar el bloque completo y su margen; no inventar aniversarios.
- Toda la tarjeta es pulsable y utiliza la acción existente de abrir Planes.
  El enlace dice «Ver planes»: no promete abrir un evento remoto todavía inexistente.
- Recalcular al recibir datos, a medianoche local y al volver del segundo plano.
  El temporizador se cancela al desmontar el componente.

El cálculo usa año/mes/día locales convertidos a un índice UTC para restar días
naturales; evita que un cambio horario convierta una diferencia de días en 23 o
25 horas. Una fecha recibida en UTC se convierte primero a la zona del dispositivo.
No se aplica recurrencia anual implícita: el servicio deberá entregar la siguiente
ocurrencia explícita, incluida cualquier decisión de producto sobre el 29 de febrero.

## Medidas de la tarjeta

| Elemento | Medida lógica |
| --- | --- |
| Posición | Después del saludo y antes de Instantáneas |
| Margen lateral | 16, heredado del dashboard |
| Ancho a 390 / 412 | 358 / 380 |
| Radio exterior | 24 |
| Padding | 16 |
| Separación hasta Instantáneas | 16 |
| Etiqueta e icono corazón | Nunito 12/20; Lucide 16 |
| Nombre de la ocasión | Fredoka 20/24, peso 600 |
| Cuenta atrás | Nunito 14/20, peso 800 |
| Ver planes | Nunito 12/20, chevron-right 16 |
| Bloque de fecha | 84×84, radio 20, borde 1 |
| Número del día | Fredoka 32/36, peso 600 |
| Mes | Nunito 12/20, peso 800, espaciado 1.2 |
| Espacio texto/fecha | 16 |

El alto depende del contenido, sin forzar recortes en el título. Para texto grande
(más del 150%) o un interior menor de 260, apilar la fecha sobre el texto. El bloque
cuadrado crece con la escala tipográfica y conserva su proporción. Se comprobó
el dashboard en 320, 390 y 412 con texto al 100% y 200%.

Superficie `note`, texto `ink`, secundarios `secondary`, bloque `background` y borde
`border`. No se usa el color de acción de cámara para competir con Instantáneas.
La fecha completa está disponible para lectores de pantalla.

## Widget de pantalla de inicio del teléfono — propuesta visual

`DateHomeWidgetPreview` especifica el aspecto; **no instala un widget nativo**.
Se representa un cuadrado de referencia de 180×180, radio 28 y padding 14.
Contiene icono corazón, «Próxima fecha», fecha abreviada, título de hasta dos líneas
y cuenta atrás. Usa los mismos tokens de color. Su acción prevista es abrir Planes.

A diferencia de la tarjeta, el widget debería mostrar la próxima ocasión aunque
falte más de una semana. Sin ocasiones: «Sus próximos días especiales» y
«Abrir Romanza». Las dimensiones finales de Android dependen del launcher y de sus
celdas; 180×180 es una referencia visual, no una garantía para todas las grillas 2×2.
El prototipo del teléfono se revisó visualmente a escala tipográfica normal; las
variantes nativas deberán resolver escalado y redimensionado en cada plataforma.

### Trabajo necesario para hacerlo instalable

1. Conectar fechas reales autorizadas y definir dónde se crean/editan. Los borradores
   actuales de Planes no se convierten automáticamente en fechas importantes.
2. Android: proveedor AppWidget (RemoteViews o Glance), metadatos/tamaños, estado
   local mínimo y apertura segura a Planes. iOS: extensión WidgetKit y App Group.
3. Persistir el siguiente evento y tema mediante un contrato compartido; actualizar
   al cambiar fechas y pedir refresco de cronología diario. El sistema decide cuándo
   ejecutar actualizaciones en segundo plano; no prometer refresco al segundo.
4. Vaciar datos del widget al cerrar sesión o desvincularse y volver a validar
   autorización al abrir la app. Ofrecer ocultar el nombre de la ocasión por privacidad.
5. Verificar instalación, tamaños reales, cambio de día, tema, escalado y enlaces
   profundos en Pixel y iPhone. No duplicar alarmas ni solicitar permisos de
   notificación solo para representar una fecha en pantalla.

## Alcance de esta entrega

La tarjeta está implementada como componente Flutter e integrada en TodayScreen;
HomeShell expone la entrada de datos. El estado real sigue vacío hasta conectar
las ocasiones autorizadas. El widget del teléfono es una **propuesta visual** Flutter,
sin proveedor Android, extensión iOS, publicación en tiendas ni instalación física.
Las capturas usan una ocasión ficticia de prueba y fecha fija para poder repetirlas.

Recursos: `lib/features/today/important_date.dart`, `upcoming_date_card.dart`,
`date_home_widget_preview.dart` y `test/upcoming_date_test.dart`.
Capturas: `docs/qa/evidence/important-date/`.

```
flutter analyze --no-pub
flutter test --no-pub
flutter test --no-pub --dart-define=CAPTURE_DATES=true test/upcoming_date_test.dart
```
