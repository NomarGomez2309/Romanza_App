# Validación de la entrega visual

## Comprobado

- Flutter 3.41.9 / Dart 3.11.5 en Windows.
- flutter analyze: sin incidencias.
- flutter test --dart-define=CAPTURE_VISUALS=true: 16 pruebas aprobadas.
- Matriz de nueve layouts: Default/Forest/Neo × 390×844, 412×924 y 320×640.
- Escalas 100% y 200%, desplazamiento y navegación; fotos con ratio 0,86 a 100%.
- Inicio pendiente/error/reintento; restauración de paleta con repositorio de
  prueba; errores de lectura y escritura sin mostrar un guardado ficticio.
- Guías automáticas de áreas táctiles Android y nombres accesibles aprobadas.
- Contraste mínimo 4,5:1 para texto principal/secundario sobre fondo y tarjetas,
  y texto sobre primario en las tres paletas.
- Capturas revisadas en build/visual-review: nueve variantes de Hoy,
  preferencias, Recuerdos vacío y pantalla pequeña con texto al 200%.
- Android: :app:testDebugUnitTest :app:lintDebug :app:assembleDebug.
  La tarea nativa de pruebas es NO-SOURCE; las 16 pruebas son Flutter.

## Ajustes encontrados por las pruebas

Las decoraciones de instantáneas se adaptan al espacio libre en 320 de ancho,
sin reducir texto. Se corrigió la altura de navegación para mantener contenido
visible. Forest conserva sus cuatro colores base y ajusta únicamente roles de
texto derivados: #111A08 sobre primario y #4D5E26 para texto secundario.

## Límites

En la entrega inicial no había un dispositivo Android conectado. La auditoría posterior del Pixel 9 está enlazada al final. No se ha probado Firebase real,
persistencia nativa tras cierre del proceso, TalkBack/VoiceOver, iOS ni macOS.
El texto al 200% produce varias líneas en pantallas estrechas; se mantiene legible
sin desbordamiento y permite desplazamiento. Las capturas son del renderizador
Flutter de pruebas con fuentes reales, no capturas de un teléfono físico.

Web necesita configuración Firebase propia para el punto de entrada normal;
la vista visual_preview omite Firebase expresamente y no persiste la paleta.
Los Podfile.lock de Apple requieren regeneración con CocoaPods en macOS.
Lint mantiene una advertencia anterior de drawable-v21 redundante; no hay errores.
Las reglas de 24 horas y autoría están documentadas, sin implementación remota.

## Auditoría posterior en Pixel 9

El 8 de noviembre se validaron las pantallas en un Pixel 9 físico, incluido el guardado de paleta tras cerrar el proceso. Se registraron cuatro incidencias pendientes: contraste de Entendido, objetivo táctil de Hoy, etiquetas de navegación con texto grande y localización de accesibilidad. Las 16 pruebas anteriores pasan; el ensayo adicional reproduce dos fallos de contraste.

[Informe y pasos de reproducción](qa/visual-audit-2026-11-08.md).
