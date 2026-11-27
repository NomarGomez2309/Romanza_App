# Limpieza documental del 27 de noviembre de 2026

Referencia: `Romanza/Dart`, commit `846c096a`. Se compararon los contratos con el
código de Hoy, Temas, Configuración, bienvenida, cámara, navegación y Recuerdos;
se revisaron los mockups y el contenido de los paquetes candidatos.

## Cambios

- Sistema visual consolidado: paletas, tipografía y medidas actuales. Retiradas
  instrucciones de avatar64/grupo118, máximo520, barra72 y biblioteca175/243.
- Actualizados Hoy, Configuración, Temas, iconografía, acceso/cuenta, roadmap,
  validación e índices. Se mantienen contratos de seguridad y funciones pendientes.
- Eliminados contratos sustituidos camera.md/memories.md; conservación, autoría
  y privacidad de Recuerdos se incorporan a su contrato vigente.
- Retirados dos informes visuales antiguos que remitían a pantallas sustituidas,
  tres comparativas de encabezado y una captura de bienvenida anterior a ondas/hilos.
  Los informes técnicos restantes conservan su fecha y no son guías visuales.
- Documento de paletas corregido sin cambiar los doce colores base aprobados.
- Sustitución del índice, especificación y tokens de Drive por datos actuales.
- Catálogo activo depurado: 45 archivos antiguos de Romanza y 14 copias de Drive
  pasan a papelera recuperable. El detalle está en el manifiesto adjunto.

## Criterios

Retirar: wordmark antiguo en Inicio, navegación sustituida, cámara con galería,
menú con etiquetas anteriores, antigua rueda principal de preferencias, vistas de
Recuerdos anteriores a su biblioteca y variaciones explícitamente reemplazadas.
Los paquetes mixtos se sustituyen por el conjunto vigente; fuentes, licencias,
logos y SVG utilizados por la app permanecen disponibles.

Conservar: las tres paletas, el acabado actual de cuenta, la última referencia
visual de bienvenida, recursos de ondas, iconografía y licencias, propuesta Custom
Duo simplificada, investigación legal y propuestas pendientes claramente rotuladas.
El material de marketing y las referencias externas no se tratan como contratos UI.

## Validación y alcance

Comprobación de enlaces Markdown locales, referencias a ficheros retirados,
preservación de las reglas de publicación/autoría, inspección visual del documento
de paletas y comparación de los tokens consolidados con sus componentes.
`git diff --check` sin incidencias. Solo documentación y capturas de referencia:
no se modifican código de app, dependencias, fotos privadas ni configuración Firebase.
No es una nueva ejecución de las 241 pruebas registradas en el último cierre UI.

[Manifiesto de archivos](documentation-cleanup-manifest.json).
Git conserva las versiones retiradas del repositorio. Las eliminaciones de Drive
y de archivos personales se hacen en papelera, sin vaciado ni borrado definitivo.
