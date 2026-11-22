# Planes — prototipo interactivo Flutter

Se adapta la referencia aportada por el usuario: fecha protagonista, superficies
amplias redondeadas, tarjetas con horario de inicio/fin y dos modos de consulta.
La identidad usa Fredoka, Nunito, recursos Lucide/Romanza y `RomanzaColors`.
Base de trabajo: `5295a5de` en `Romanza/Dart`.

## Experiencia

- Cabecera Planes, subtítulo «Algo bonito por hacer, juntos.» y botón + de 52.
- Selector «Día / Calendario» con zonas táctiles de al menos48. Se usa «Día» para
  distinguirlo de la pestaña global Hoy.
- Día: día de semana, fecha grande en dos líneas y «Un rato para ustedes» con
  símbolo vínculo. Flechas anterior/siguiente e «Ir a hoy». Lista ordenada por
  hora del día elegido; contador de pendientes y estado vacío accionable.
- Calendario: navegación mensual con año visible, semana compacta, indicadores
  de fechas con planes y despliegue del mes completo. El mes utiliza semanas de
  lunes a domingo y la longitud real de cada mes. Elegir una fecha abre su Día.
  La agenda inferior agrupa los planes del mes por fecha y hora.
- Tarjetas enteramente pulsables: nombre, tipo, badge, inicio, duración y fin.
  Se explicita la fecha final cuando termina al día siguiente. Tipos Cita,
  En casa, Salida y A distancia; colores tomados de plan/note/memory del tema.
- + abre un editor inferior con título (obligatorio,80 caracteres), fecha,
  hora, duración30/60/90/120 minutos y tipo. La edición conserva estos datos.
- Detalle: marcar realizado/pendiente, editar, eliminar con Deshacer.

## Alcance real de esta entrega

Es un prototipo funcional de UI, identificado en pantalla como «Vista de diseño».
Los borradores viven en la sesión del widget: sobreviven al cambio de pestaña y
al tema, y se descartan al cerrar sesión, reiniciar o destruir la pantalla.
No se muestran planes de ejemplo en cuentas reales. Los ejemplos de las capturas
se inyectan únicamente desde pruebas. No se simulan avatares ni pareja vinculada.

La hora corresponde al dispositivo. No se presentan relojes de una pareja ni se
simula conversión de zonas horarias. No se crean eventos remotos, recordatorios,
notificaciones, permisos, reglas o persistencia compartida. Para conectar el
servicio real hará falta definir autoría/permisos, almacenamiento, sincronización,
zona horaria y estados de envío. El mockup no constituye esa integración.

## Medidas y accesibilidad

| Elemento | Medida lógica |
| --- | --- |
| Contenido | Máximo552; margen16 reutilizando RomanzaPage |
| Título | Fredoka34/40,600 |
| Subtítulo | Nunito15/20 |
| Botón crear | Mínimo52×52; radio20; Lucide Plus24 |
| Selector de modo | Mínimo48; cápsulas; separación8 |
| Fecha del día | Fredoka58/58,500 |
| Título de lista | Fredoka25/32,600 |
| Tarjeta | Radio28; padding20; separación12 |
| Nombre del plan | Fredoka26/29.12,600 |
| Horarios | Fredoka24/28,500 |
| Etiquetas | Nunito12/20 |
| Calendario | Radio28; padding12; celdas con alto mínimo48 |
| Editor | Margen24; contenido desplazable y padding del teclado |

Se respeta escalado de texto y scroll; los horarios usan Wrap cuando no caben.
El cambio de cabecera se anima en200ms mediante AnimatedSize, y pasa a duración
cero si el sistema solicita reducir animaciones. Iconos decorativos excluidos de
semántica; fechas seleccionadas y días con planes anunciados. Flechas con tooltip.
La navegación inferior existente y el dashboard conservan su geometría.

## Archivos y verificación

- `lib/features/plans/plans_screen.dart`: vistas Día/Calendario, tarjetas y estado.
- `plan_draft.dart`: modelo inmutable y formato local del prototipo.
- `plan_editor.dart`: formulario de creación/edición.
- `lib/features/home_shell.dart`: reemplaza la pantalla vacía por PlansScreen.
- `test/plans_screen_test.dart`: altas, edición, completar, borrar/deshacer,
  navegación mensual/filtro diario y fin al día siguiente. También composición
  de tres paletas ×390/412×texto100/200% y formulario.

```
flutter analyze --no-pub
flutter test --no-pub --dart-define=CAPTURE_PLANS=true test/plans_screen_test.dart
flutter test --no-pub
```

Capturas con datos ficticios: `docs/qa/evidence/plans/`, en los modos Día y
Calendario para Default/Forest/Neo. Son renders Flutter; no prueban instalación
Pixel ni escritura en Firebase.
