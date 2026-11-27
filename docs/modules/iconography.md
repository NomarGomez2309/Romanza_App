# Iconografía v2.3

Integración Flutter de Romanza_Iconografia_v2_3.md y sus recursos locales. La guía está fechada 13/11; esta implementación y validación se realizan el 12/11/2026.

## Recursos y roles

28 SVG originales del paquete: 24 Lucide y 4 adaptaciones Romanza, conservados sin modificar. `RomanzaSymbol` centraliza las rutas y `RomanzaIcon` renderiza con flutter_svg y tintado del tema. La licencia se incluye en el bundle y en Configuración → Términos y condiciones → Licencias de terceros; manifest.json conserva la procedencia.

Hoy usa romanza-hoy; Planes, calendar-days; Recuerdos, romanza-recuerdos; Notas, romanza-nota. Configuración utiliza user-round, sliders-horizontal, link, globe, file-text y log-out. Cámara usa x, zap/zap-off y switch-camera. Las flechas direccionales pueden reflejar arrow-left; las filas con chevron usan el SVG chevron-right. Los recursos de acciones todavía inexistentes se conservan en el catálogo sin inventar funcionalidades.

SVG decorativos excluidos de semántica; nombre, selección y acción permanecen en el control. No hay selector de familias ni acceso a galería. Publicar sigue bloqueado hasta disponer de cuentas y vínculo. El disparador conserva los dos círculos v4.

## Geometría

La geometría y las variantes rellenas de navegación se rigen por
[la barra flotante](floating-navigation.md). Esa especificación sustituye las
medidas de pastilla y transición anteriores. El resto de símbolos permanece
con trazo, salvo sus variantes de navegación seleccionada/pulsada.

Configuración: iconos 24 y filas mínimas 64. Insignias de nota/plan: 26 dentro de 44. Añadir: 28 dentro de 52 × 44 y toque de 48 de alto. Cerrar: 22; flash y giro: 28, manteniendo sus zonas táctiles. Añadir usa acento y un color sobre acento con contraste calculado; navegación utiliza primario/sobre primario.

Se retiraron los glifos Material explícitos de las pantallas y los trazos manuales de controles de cámara. Los widgets del sistema conservan su comportamiento nativo.
