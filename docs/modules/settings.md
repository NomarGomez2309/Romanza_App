# Configuración

Panel inferior desde los perfiles unidos del dashboard. Título y X, resumen de
cuenta pulsable y cinco opciones: Temas, Mi Pareja, Idioma, Términos y condiciones,
Cerrar sesión. Las claves internas Preferencias/Administración de pareja se
conservan para las rutas; no son los nombres visibles.

## Medidas y vidrio

Radio superior 24; título Fredoka26/32 peso600. Cuenta: alto mínimo104, radio20,
padding16 horizontal/12 vertical, avatar46 y pareja27.6. Texto de cuenta Nunito
13.8/18; nombre19.55/24 peso600; vínculo14.95/20. Nombres largos pueden crecer.

Filas con icono24, Nunito17/24, padding lateral27, gap icono/texto19 y padding
vertical17; ListTile tiene mínimo58, y su alto efectivo crece con contenido/padding.
La cabecera y el contenido se desplazan cuando hace falta. No fijar alto del panel
ni posiciones Y por teléfono.

Blur20.52; superficie note al77%; borde blanco25.3%; sombra negra8%, blur16,
desplazamiento vertical-2. Alto contraste o navegación accesible: superficie sólida
sin blur. Texto, imágenes y controles permanecen nítidos. Estos valores sustituyen
las variantes18/32 y sus porcentajes intermedios.

## Comportamiento

Cuenta abre `AccountScreen`: nombre editable, correo propio, estado de verificación
y recuperación para contraseña. Foto del proveedor o fallback; sin editor/subida
nuevo. Mi Pareja conserva sus estados de carga/sin vínculo/error; no se simulan
invitaciones. Temas abre la página de paletas. Idioma: dispositivo o español.
Los textos legales están identificados como borradores.

Cerrar sesión usa la sesión real cuando existe, deshabilita repetición y muestra
error si falla. Cerrar con X, atrás, barrera o arrastre devuelve el foco al origen;
el fondo no recibe interacción. Durante cierre de sesión se bloquea el retorno.
Transición250ms o instantánea con reducir movimiento.

[Cuenta y autenticación](onboarding-account.md) · [Temas](preferences.md).
