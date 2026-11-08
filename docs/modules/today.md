# Hoy y navegación

## Objetivo y alcance

Primera entrega visual basada en Romanza_Diseno_Recursos_Medidas_v1.docx y las
grillas Pixel 9/iPhone 14 del usuario. Implementa Hoy, navegación fija a Planes
y Recuerdos, y acceso a preferencias. No consume ni inventa datos compartidos.

## Componentes y adaptación

CoupleHeader, InstantMomentsSection, MomentCard, RomanzaPreviewCard,
RomanzaBadge, RomanzaNavigation, RomanzaPage y RomanzaEmptyState. Colores y
texto centralizados en design_system. Tarjetas regulares, nota con trébol,
plan con hexágono redondeado y recuerdo con miniatura vacía. Iconos Material
provisionales; no se incorporan fotografías de muestra ni capturas como UI.

SafeArea real, fotos con ancho/alto 0,86 a escala 100%, scroll independiente
por pestaña y límite de ancho en ventanas grandes. La fila de + reserva 48
para el toque y 8 hasta las fotos: conserva el flujo equivalente de 44+12.
Con texto ampliado aumentan tarjetas y navegación; el encabezado puede fluir
a otra línea. Solo las decoraciones se reducen cuando falta espacio, no el texto.

## Acciones y estados

Hoy muestra ausencia de pareja, instantáneas y contenido. El contador no aparece
sin fecha real. +, cada instantánea y la nota abren una explicación breve, sin
prometer una subida o edición actual. Plan y recuerdo navegan a su sección vacía.
Avatares abren Usuario → Preferencias → Paleta de colores (agrupados en una vista).
No hay formularios, permisos de cámara ni reproducción en esta entrega.
Carga y error de Firebase se resuelven en el arranque. Los estados de carga/error
de contenido remoto se implementarán al incorporar sus repositorios.

## Accesibilidad y validación

Texto del sistema sin reducción automática; decoraciones fuera del árbol
semántico, nombres de controles, selección de navegación y áreas de toque.
Pruebas de layout para 390×844, 412×924 y 320×640, tres paletas, escala 100% y
200%, proporción de fotos, navegación, objetivos táctiles y contraste de texto.
Revisión con TalkBack/VoiceOver y validación en hardware pendientes.
