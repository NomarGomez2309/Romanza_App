# Configuración v2

## Objetivo y fuente
Panel inferior desde avatares, según ESPECIFICACION.md v2.1 y 01_Pantalla.svg.
Exactamente seis filas: Cuenta, Preferencias, Administración de pareja, Idioma,
Términos y condiciones, Cerrar sesión. Solo icono y nombre, sin tarjetas/subtítulos.

## Componentes y adaptación
SettingsSheet y SettingsDetail. Radio24, filas mínimo64, iconos24, Nunito17/24;
Fredoka25/32 en título. Scroll limitado al espacio seguro. Tinte del tema80%,
blur18 y borde blanco22%; superficie opaca con alto contraste o navegación
accesible. Animación250ms o sin animación si el sistema reduce movimiento.
Modal bloquea el fondo; X, atrás, arrastre y barrera cierran el panel.

## Acciones y estados
Preferencias abre su página. Cuenta y pareja explican honestamente la ausencia de
identidad y vínculo; no simulan invitaciones ni cierre de sesión. Términos ofrece
los dos destinos previstos, con aviso de contenido pendiente, sin textos legales
inventados. Idioma permite dispositivo o español: único idioma traducido y fallback.
Preferencia de idioma confirmada al persistir, con progreso y error/reintento.
Localizaciones Material/Cupertino/Widgets en español: Atrás, barrera y diálogos.

## Pruebas y límites
Seis filas verificadas, navegación y layouts con texto200%, estrecho y horizontal.
No son flujos de autenticación ni administración de pareja implementados.
Sin certificación de lector de pantalla. El sistema no expone una señal Flutter
universal de reducción de transparencia; alto contraste y navegación accesible
activan el fallback sólido.
