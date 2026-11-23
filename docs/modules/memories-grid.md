# Recuerdos — grilla Romanza

Propuesta de presentación adaptada de la referencia de Fotos aportada por el
usuario. Mantiene Fredoka/Nunito, Lucide/Romanza, los radios y las paletas del
proyecto, y reutiliza la barra flotante ya integrada. Base `2aac5121`.

## Vistas y recorridos

- **Fotos / Todas**: biblioteca ordenada de más reciente a más antigua. Mosaico
  de tres columnas, fotos cuadradas y fecha breve sobre fade negro inferior.
  El control de tamaño alterna entre tres y dos columnas.
- **Fotos / Meses**: grupos por mes/año local, con nombre, cantidad y mosaico de
  una foto amplia y dos pequeñas. Un grupo de dos o una foto adapta su composición.
  Pulsar abre únicamente las fotos de ese mes.
- **Fotos / Años**: portadas amplias con año y cantidad. Pulsar abre ese año.
- **Colecciones**: portada «Nuestro libro» con toda la biblioteca y tarjetas de
  álbum Nosotros, Escapadas y Lo cotidiano. Solo se muestran categorías con datos.
  Las categorías proceden del modelo; no se infieren por reconocimiento facial.
- **Visor**: fotografía completa con ajuste contain, fecha y texto opcional,
  anterior/siguiente, contador y tira de miniaturas. Admite deslizamiento horizontal;
  pulsar una miniatura cambia la foto. La tira sigue la posición seleccionada.
  Volver conserva la vista de biblioteca y su posición de scroll.

La cámara conserva la acción existente «Preparar una foto»; no se añade subida
desde galería. La ausencia de recuerdos sigue ofreciendo el estado vacío y la
preparación de un borrador. Nunca se representa un borrador local como publicado.

## Medidas lógicas

| Elemento | Valor |
| --- | --- |
| Contenido | Máximo552; margen horizontal16 |
| Cabecera | Padding superior20, título Fredoka34/40,600 |
| Subtítulo | Nunito15/20; separación6 |
| Cámara | Área48×48; radio18; icono24 |
| Selector Fotos/Colecciones | Alto mínimo48; cápsula; separación8; altura común adaptable |
| Agrupaciones | ChoiceChip cápsula, separación6, Nunito14/20 |
| Grilla | 3 columnas por defecto; gap6 horizontal/vertical; ratio1:1 |
| Grilla ampliada | 2 columnas; se reduce más con texto grande si hace falta |
| Foto | Radio16; fecha Nunito11/14,700; padding8 lateral/inferior y20 superior |
| Fecha sobre imagen | Fade transparente/negro0.65/negro0.79, stops0/0.5/1 |
| Tarjeta de mes | Radio24; padding14; título Fredoka22/28,600 |
| Mosaico interior | Radio12; separación6; proporción de columnas2:1 |
| Portadas año/libro | Radio24; alto210 más ajuste de escalado; padding20 |
| Álbumes | 2 columnas normales, gap12; radio24; portada ratio1.3 |
| Nombre de álbum | Fredoka16/20,500; cantidad Nunito12/20 |
| Visor | Imagen con margen16, radio24; miniatura58, gap6, radio12/8 |
| Botones anterior/siguiente | Área táctil de IconButton48; icono22 |
| Scroll inferior | 24 + inset de la barra flotante/área segura |

Biblioteca sin área segura lateral adicional:

| Pantalla | Ancho útil | 3 columnas | 2 columnas |
| --- | --- | --- | --- |
| 390×844 (referencia iPhone14) | 358 | 115.33 | 176 |
| 412×924 (referencia Android/Pixel9) | 380 | 122.67 | 187 |

Estos son tamaños lógicos de referencia; las áreas seguras reales las suministra
Flutter. No se fijan las coordenadas al modelo de teléfono ni se fuerza su altura.
Se deja contenido desplazable detrás de la barra; el padding final permite subir
la última foto por encima de ella.

La biblioteca calcula columnas por ancho disponible y textScaler; con texto200%
usa dos en390/412 y una en320. Los álbumes pasan a una columna con texto grande.
No se reduce el texto del usuario para encajarlo. Los títulos y cantidades pueden
crecer, y los metadatos del visor tienen scroll acotado para conservar la imagen.

## Color, tipografía e iconos

Las superficies provienen de RomanzaColors. El estado de agrupación usa note,
las cápsulas ink/background y los controles primary/onPrimary. Se evitan los
colores automáticos ajenos a la paleta. Las fotos conservan sus colores reales;
solo se añade el fade para la fecha. La grilla de producción usa un tema neutro
exclusivamente en pruebas; no añade un cuarto preset a la aplicación.

Se reutilizan cámara, imágenes, chevron-right, flechas, corazón y navegación.
Las fotos tienen etiqueta accesible con la fecha completa. El fallo de decodificación
muestra un icono con «Foto no disponible»; la carga reserva su geometría con una
superficie e icono estáticos. No se anima de manera continua el mosaico.

El visor consulta reducir movimiento para hacer instantáneos los cambios por
botón y el desplazamiento de la tira. El gesto manual de PageView se conserva.

## Datos y alcance de producción

MemoryRecord es una entrada de presentación: id, ImageProvider, publishedAt,
colección y caption. El llamador debe aportar registros publicados y autorizados.
HomeShell continúa pasando una lista vacía hasta integrar el servicio real.
Los18 bloques grises de las capturas son fixtures de pruebas; no se crean en
cuentas reales ni se suben como recuerdos.

Esta entrega no añade Firestore/Storage, selección de archivos, publicación,
reconocimiento de personas, borrado ni cambios de permisos. No hay acciones de
eliminar que permitan simular autoridad sobre fotos ajenas. La integración del
servicio debe conservar el acuerdo de producto: biblioteca privada para ambos,
y eliminación permitida únicamente al autor, verificada también por el backend.
No se presenta la UI como prueba de ese control de acceso.

Fechas agrupadas en la zona local del dispositivo y texto de fecha completa
mediante MaterialLocalizations, coherente con la aplicación en español.
El modelo actual cubre fotos; no se simula reproducción de vídeos.

## Implementación y recursos

- `lib/features/memories/memories_screen.dart`: vistas, agrupación, slivers y modelo.
- `memory_tiles.dart`: fotos, fades, mosaicos y portadas.
- `memory_viewer.dart`: PageView, contador y tira de miniaturas.
- `test/memories_grid_test.dart`: orden, densidad, filtros, colecciones, visor,
  error accesible y composiciones en dos tamaños, tres paletas y texto100/200%.
- `docs/qa/evidence/memories/`: grillas neutras390/412, comparativa de cinco vistas
  y renders de Default, Forest y Neo. Son imágenes de Flutter, no capturas de Apple.

```
flutter analyze --no-pub
flutter test --no-pub
flutter test --no-pub --dart-define=CAPTURE_MEMORIES=true test/memories_grid_test.dart
```
