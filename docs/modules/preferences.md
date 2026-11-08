# Preferencias de apariencia

## Objetivo y alcance

Selector Default/Forest/Neo en Usuario → Preferencias → Paleta de colores.
Default inicial; Custom no implementado. La opción elegida aplica a toda la app.

## Componentes y estados

Reutiliza RomanzaPage, tipografía y roles compartidos. Cada opción incluye nombre,
muestras de color e indicador de selección; la selección no se distingue solo
por color. Carga inicial en el arranque; guardado con progreso y bloqueo temporal
de selección repetida; fallo visible con elección anterior conservada.

## Persistencia y límites

PaletteController → PaletteRepository → SharedPreferencesAsync. Preferencia local
al dispositivo, sin sincronización ni cuenta. Un valor desconocido usa Default;
un fallo de lectura se informa en esta pantalla. Elegir otra vez permite reintento.
La entrada visual_preview usa memoria deliberadamente para desarrollo.

## Pruebas

Elección y restauración al recrear la app con repositorio de prueba; fallos de
lectura/escritura; inspección visual. Persistencia nativa real tras reiniciar el
proceso queda pendiente de prueba en dispositivo. No hay datos personales.
