# Preferencias v2

## Objetivo y fuentes
Página independiente desde Configuración. ESPECIFICACION.md v2.1, tokens y
02_Pantalla.svg aportados por el usuario. Flutter confirmado expresamente;
sin migración nativa ni cambios de estructura de Hoy o Planes.

## Componentes y adaptación
Default, Forest y Neo mantienen sus bases. ChoiceChip redondeado y selección
accesible; Wrap si el texto no cabe. Rueda de radio exterior94/interior57 con dos
identificadores; Color1/2 permite seleccionar la semilla e introducir hexadecimal
validado. Arrastre en la rueda modifica la semilla activa. Espectro sin tematizar.
Fredoka/Nunito locales, márgenes16, controles48, scroll y áreas seguras.
Tres propuestas, cuatro muestras por propuesta; selección con borde y check.
Guardar permanece deshabilitado sin selección. Cambiar semillas invalida propuestas.

## Generación y persistencia
Recetas HSL deterministas para tres propuestas distintas, incluyendo semillas
iguales. Dos variantes claras y una oscura; roles derivados con texto blanco/negro
según luminancia. Pruebas de contraste sobre todas las superficies utilizadas.
Es una decisión técnica de esta entrega, no un algoritmo de marca definitivo.

PaletteController → PreferencesStore → SharedPreferencesAsync; documento v2
atómico para base, banco, selección activa e idioma. Primera carga conserva la
paleta v1 existente. Escritura confirmada antes de aplicar; progreso y error;
fallo conserva el estado confirmado. Identidad por cuatro colores evita duplicados.
Banco local sin nombres editables, eliminación ni sincronización en esta entrega.
Las entradas de desarrollo sin repositorio persistente usan estado de sesión.

## Pruebas y límites
Restauración, elección fija tras Custom, deduplicación, errores de escritura,
validación hexadecimal, invalidación y contraste. Matriz390/412/320 y horizontal,
texto100/200%. Ver informe QA v2 para resultados finales de dispositivo.
