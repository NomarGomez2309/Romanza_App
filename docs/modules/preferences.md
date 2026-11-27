# Temas y personalización

## Presets

Desde Configuración → Temas. Cuatro opciones en grilla de dos columnas: Default,
Forest, Neo y Custom con brocha Lucide. Margen16, gap12; ancho=(W−44)/2, radio20,
padding14. Cuatro franjas horizontales apiladas por preset, radio6, gap5 y pesos
16/16/30/38. Sin códigos hexadecimales en las tarjetas. Etiqueta Nunito17/24 y check22.
La altura puede crecer con el texto; no forzar un cuadrado que recorte la etiqueta.

Aplicar un preset persiste su selección. Custom abre su editor sin modificar el
tema hasta guardar. Las paletas guardadas se añaden al banco; no reemplazan los
presets ni el acceso Custom. [Colores exactos](../design-system.md).

## Custom personal

Dos semillas; editor de color con rueda y entrada hexadecimal accesible.
Cambiar semillas invalida las propuestas. Generar exactamente tres combinaciones,
seleccionar una y Guardar. El generador vigente usa recetas HSL deterministas en
`custom_palette.dart`, no una dependencia ColorScheme.fromSeed. Los roles derivados
se comprueban por contraste. La rueda es un editor de color, no la composición
antigua que reunía todos los controles en la página principal de Temas.

## Custom Duo

Acceso Duo en Temas. Dos cuadros Tú/Tu pareja, diez muestras y botón compacto
Generar combinaciones con wand-sparkles. Tocar el cuadro propio confirma solo
cuando el padre suministra una acción autorizada; el cuadro ajeno es informativo.
La vista controlada exige dos aportes confirmados para habilitar generación.

La pantalla actual únicamente permite explorar un borrador local. No inventa un
color, confirmación o consentimiento de la pareja. La sincronización y aplicación
bilateral siguen pendientes. No confundir Custom personal guardado localmente
con una paleta compartida ya operativa.

## Persistencia y estados

PaletteController → PreferencesStore → SharedPreferencesAsync. Documento atómico
para base, banco, selección e idioma; migración de paleta anterior y deduplicación
por colores. Guardar se confirma antes de aplicar; error conserva el estado
confirmado y permite reintentar. Las previews sin repositorio usan estado de sesión.

Pruebas de selección, restauración, invalidación, guardado/error, contraste,
layouts y escalado. Sin sincronización remota del banco ni monetización implementada.
