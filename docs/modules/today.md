# Hoy

## Estructura vigente

`TodayScreen` usa `RomanzaPage`, ancho máximo 552 y margen 16. Orden:
símbolo y perfiles unidos; saludo «Hoy, contigo» y estado de pareja; tarjeta de
fecha próxima cuando corresponde; Instantáneas con + y dos momentos; nota;
próximo plan; recuerdo. La barra flotante se documenta por separado.

`CoupleHeader`: fila 72; símbolo 41.6×29.25, avatares 41.6, grupo 76.7,
unión 15.6 y corazón 11.05. El dashboard no lleva wordmark. El acceso a cuenta
mantiene altura táctil 48 y abre Configuración.

Las instantáneas tienen ratio ancho/alto 0.86, gap 8 y radio 16; crecen con texto.
Nota y plan conservan tarjetas regulares e insignias de trébol/hexágono; recuerdo
usa miniatura 80×52, radio 12. Iconos Lucide/Romanza, sin glifos provisionales.

## Acciones y estados

El botón + y Tu momento abren la cámara directa 1:1, sin galería. Su momento
explica la ausencia de contenido vinculado cuando corresponde. Nota todavía
informa su estado pendiente. Planes y Recuerdos abren sus vistas actuales.

No se inventan nombres, fotos, días de relación ni vínculos. Sin fecha de relación
no aparece un contador ficticio. `importantDates` recibe ocasiones explícitas:
solo la más cercana entre hoy y siete días aparece sobre Instantáneas. Sin datos
se omite el bloque y su separación. [Contrato de fechas](important-dates.md).

`HomeShell` conserva las pestañas en IndexedStack. El contenido puede pasar detrás
de la barra y tiene padding final para subir el último elemento por encima de ella.
[Barra flotante y movimiento](floating-navigation.md).

## Accesibilidad y evidencia

SafeArea real, texto ampliable y scroll. Controles con nombres accesibles;
decoraciones fuera de semántica. Anchos 320/390/412 y texto 100/200% comprobados
mediante pruebas Flutter; no sustituye TalkBack/VoiceOver ni hardware.

Capturas vigentes del dashboard: `../qa/evidence/important-date/`. Las ocasiones
son fixtures de pruebas, no datos creados en una cuenta real.
