# Auditoría visual en Pixel 9

Fecha: 8 de noviembre de 2026. Base revisada: 0d541af2.
Estado: cuatro incidencias confirmadas y pendientes de corrección. Esta entrega
registra los resultados; no modifica el diseño ni la lógica de la aplicación.
No se observaron cierres inesperados durante los recorridos realizados.

## Entorno y alcance

Pixel 9 físico, Android 17/API 37, 1080×2424 y densidad 420 (aproximadamente
411×923 unidades lógicas). Ajuste inicial del usuario: texto 115%, orientación
vertical bloqueada y paleta Forest. Se restauraron esos tres ajustes al terminar.

Se recorrieron Hoy, Planes, Recuerdos, Usuario/Preferencias y el diálogo de
instantáneas. Se cambiaron las tres paletas y se comprobó la persistencia de Neo
tras forzar cierre y reabrir. Se probaron texto 200%, desplazamiento y orientación
horizontal en el teléfono. Las pruebas automatizadas cubrieron además pantallas
320×640, 412×924, 844×390 y 1024×768 con escalas lineales 100%, 115% y 200%.
El escalado real de Android es no lineal; no equivale exactamente al del test.

## Resumen

| ID | Prioridad | Hallazgo | Estado |
| --- | --- | --- | --- |
| VIS-01 | P2 | Poco contraste en Entendido con Default y Forest | Confirmado |
| VIS-02 | P2 | Área táctil de Hoy se estrecha con texto 115% | Confirmado |
| VIS-03 | P3 | Recuerdos se divide dentro de la palabra con texto 200% | Confirmado |
| VIS-04 | P3 | Etiquetas de accesibilidad en inglés | Confirmado |

P2: corregir antes de ampliar la entrega; afecta lectura o interacción.
P3: inconsistencia visual/de localización que debe corregirse antes de publicar.
No se detectaron incidencias P0/P1 en el alcance probado; esto no certifica
funciones remotas, seguridad ni plataformas no revisadas.

## VIS-01 Contraste del botón Entendido

Reproducción: Usuario → elegir Default o Forest → volver a Hoy → pulsar +.
El texto Entendido usa el primario claro sobre el fondo de la paleta.

| Paleta | Texto | Fondo | Contraste calculado |
| --- | --- | --- | --- |
| Default | #9FA0FF | #FFF3E3 | 2,14:1 |
| Forest | #7D8D39 | #F3F6F4 | 3,36:1 |
| Neo | #08CB00 | #000000 | 9,55:1 |

Resultado esperado: al menos 4,5:1 para texto normal. Default y Forest fallan;
Neo pasa. La debilidad se observa también en las capturas del Pixel.
La suite inicial solo comprobaba textos principales/secundarios y onPrimary;
no cubría el texto de los botones TextButton.

Ubicación: lib/design_system/components.dart, línea 89 (TextButton), y
lib/design_system/romanza_theme.dart (no define un estilo de TextButton que
separe el color decorativo del color de texto).
Propuesta: definir el primer plano de botones de texto en el tema compartido,
con un rol legible; mantener los cuatro colores base aprobados.

Evidencia local temporal: build/visual-audit/01-instantanea-sheet.png (Forest),
10-sheet-default.png y stress-results.txt. La prueba aislada reproduce ambos fallos.
Referencia del criterio: https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum

## VIS-02 El objetivo táctil se encoge al ampliar ligeramente el texto

Reproducción: escala 100% → observar Hoy seleccionado → aumentar texto a 115%.
La pastilla deja de mantener 80 de ancho y se ajusta al contenido. En pruebas
con fuentes reales, el InkWell de Hoy pasa de 80×56 a 38,1×59 unidades lógicas.
Planes pasa a 58,4 de ancho y Recuerdos a 86,2. La forma estrecha de Hoy se
observa en el Pixel con la configuración habitual del usuario.

Resultado esperado: nunca reducir el objetivo de toque por debajo de 48×48;
conservar una anchura visual mínima coherente con la especificación de 80.
La semántica exterior anuncia una región más amplia que el InkWell: aprobar la
guía semántica de áreas táctiles no verifica el ancho real del detector de gestos.

Ubicación: lib/features/home_shell.dart, líneas 125–134. La condición
textScaler.scale(14) <= 14 asigna ancho 80 solo a escala 100%; después usa null.
Propuesta: dar mínimo explícito al control y mantener toda la celda como objetivo
táctil, separando el dibujo de la pastilla de la superficie interactiva.

Evidencia: build/visual-audit/07-restart-neo.png y mediciones TAP TARGETS del
ensayo tools/qa/visual_audit_test.dart.

## VIS-03 Navegación fragmentada con texto grande

Reproducción en Pixel: texto 200% → abrir Recuerdos. La etiqueta aparece como
Recuerd / os, y su pastilla es más alta que las otras opciones. En 320 de ancho
y escala lineal 200%, también Planes se parte. La navegación continúa funcionando,
pero la lectura y el equilibrio visual se deterioran.

En 412 y escala lineal 200%, Hoy/Planes miden 74 de alto y Recuerdos 110.
No es un RenderFlex overflow: por eso las pruebas anteriores no lo detectaron.
Resultado esperado: etiquetas legibles sin fragmentar palabras y una estrategia
uniforme de crecimiento de la barra, sin reducir la preferencia de texto del usuario.

Ubicación: lib/features/home_shell.dart, RomanzaNavigation, Row de tres Expanded,
CrossAxisAlignment.start y Text de cada opción (líneas 114–174).
Propuesta: decidir un diseño accesible para texto grande, con anchuras y alturas
consistentes; validar visualmente las palabras completas, no solo ausencia de overflow.

Evidencia: build/visual-audit/11-default-font200-home.png y
13-default-font200-memories.png. También se reproduce en el renderizador de pruebas.

## VIS-04 Localización incompleta de controles del sistema Flutter

Reproducción: abrir Usuario y consultar su árbol de accesibilidad; después abrir
el diálogo +. Los textos propios están en español, pero los controles estándar
exponen Back, Dismiss y Scrim. El ensayo confirma locale=en_US y back=Back.

Resultado esperado: navegación y etiquetas auxiliares consistentes con el español
de la interfaz, incluidas las que recibe un lector de pantalla.
Ubicación: lib/app.dart, MaterialApp, línea 48; no configura localizaciones españolas.
Propuesta: incorporar flutter_localizations, idiomas soportados y traducciones
coherentes de los controles. Verificar con TalkBack tras corregirlo.

Evidencia: árbol UI del Pixel en build/visual-audit/01-instantanea-sheet.xml y
02-preferences-default.xml (el nombre de este segundo archivo es histórico;
la paleta seleccionada que contiene es Forest). No se activó TalkBack: se verificó
el árbol semántico, no la pronunciación del lector.

## Comprobaciones satisfactorias

- Apertura, navegación entre pestañas, apertura/cierre del diálogo y regreso de Usuario.
- Aplicación de Default, Forest y Neo sin reiniciar; persistencia de Neo tras cierre
  completo del proceso y reapertura. No se borraron datos de la aplicación.
- Scroll de contenido al 200%, tarjetas que crecen, orientación horizontal y
  retorno a vertical. No se registraron desbordamientos en los 12 escenarios extra.
- Las fuentes y los iconos cargan en el dispositivo. Las tres paletas se aplican
  a los componentes de la app; las zonas seguras no tapan los controles revisados.
- 16 pruebas originales aprobadas. Análisis estático sin incidencias.
- Gradle testDebugUnitTest, lintDebug y assembleDebug correctos. La tarea de
  pruebas nativas es NO-SOURCE; no se cuenta como cobertura adicional.

En algunas capturas inmediatas cambiaban los iconos de la barra del sistema.
No se confirmó un defecto estable: la barra se mostró correctamente tras
estabilizar la pantalla/reabrir. No se incluye como incidencia confirmada.

## Ensayo reproducible y límites

Ejecutar desde la raíz:

```powershell
flutter test
flutter test tools/qa/visual_audit_test.dart
flutter analyze
.\android\gradlew.bat -p android :app:testDebugUnitTest :app:lintDebug :app:assembleDebug
```

El ensayo adicional queda fuera de test/ para ejecutarlo expresamente. Su resultado
actual es 13 aprobadas y 2 fallidas, correspondientes a VIS-01. Imprime medidas de
controles para VIS-02/VIS-03 y localización para VIS-04. El fallo es una evidencia
pendiente, no una corrección. Al reparar los defectos, incorporar regresiones a
la suite habitual y ampliar las aserciones de tamaño y localización.

Las evidencias del teléfono quedan solo en build/visual-audit, ignorado por Git;
no se indexan ni versionan capturas o metadatos personales del dispositivo.
Pueden desaparecer con flutter clean; los pasos y resultados numéricos quedan
en este informe. El índice documental solo incorpora este informe.

No se probaron iOS, teclado físico, TalkBack/VoiceOver, permisos de cámara ni
contenido real. Subida de medios, vencimiento, autoría y sincronización siguen
fuera de la entrega visual y no se califican como bugs por no estar implementados.
