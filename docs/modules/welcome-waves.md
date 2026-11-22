# Bienvenida Romanza — ondas y tres temas

Revisión aprobada: 21 de noviembre de 2026. Sustituye únicamente la bienvenida
con tarjetas de onboarding v1. Implementada sobre `Romanza/Dart` tras PR #8.

## Composición

Pantalla con fondo del tema, ondas periféricas suaves y dos hilos de conexión; sin tarjetas de pareja,
píldora «A su ritmo», carrusel ni animación. Las ondas se dibujan como curvas
vectoriales con gradientes, sombras de contacto difuminadas y un borde iluminado
recortado dentro de cada capa para producir relieve; el centro queda libre.
La trama completa (capas, sombras y luces) tiene opacidad global del 15%,
compuesta como un grupo sobre el fondo. Logo, texto y controles quedan al 100%.
Un RepaintBoundary aísla la decoración estática de los cambios de estado. No se usa un mockup rasterizado
como interfaz. Las formas reproducen la dirección visual aprobada; el render
Flutter es la referencia implementable para medidas y fuentes reales.

Marca alineada a la izquierda: símbolo SVG existente y texto «Romanza» en Fredoka
26/32, eje variable 650. En Neo se usa la variación aprobada para esta
pantalla: R verde y corazón claro (`Welcome-Neo.svg`); el logo del dashboard
conserva su propio recurso. Titular Fredoka 40/44, peso 600:
«Más cotidiano. / Más Romanza.». Cuerpo Nunito 18/26, color secundario del tema:
«Un espacio para compartir sus días y guardar lo que importa, incluso a la distancia.»

| Elemento | Unidades lógicas |
| --- | --- |
| Ancho máximo del contenido | 480 |
| Márgenes laterales | 24, además del área segura |
| Espacio superior desde área segura | 15% de la altura segura, limitado a 48–136 |
| Símbolo | 41.6 × 29.25 |
| Símbolo → palabra | 10 |
| Marca → titular | 36 |
| Titular → descripción | 16 |
| Descripción → botones | 6.5% de altura segura, limitado a 32–60 |
| Botones | Alto mínimo 56; radio cápsula; padding 18 horizontal y 14 vertical |
| Icono → etiqueta | 12; icono 24 × 24 |
| Entre botones | 14 |
| Botones → enlace | 8; enlace con área táctil mínima 48 |
| Margen inferior | 18% de altura segura, limitado a 64–166 |

Se conserva el escalado de texto del dispositivo. Botones y contenido crecen;
si no caben se desplazan verticalmente. SafeArea respeta recortes y navegación.
Las ondas ignoran eventos y semántica. El logo se anuncia una sola vez, los iconos
de botones son decorativos y las etiquetas explican la acción. No se fija la
pantalla a una resolución ni se reduce texto para encajarlo.

## Motivo de conexión aprobado

Se mantienen las ondas con relieve al 15% de opacidad, ahora en bandas bajas y
poco profundas en los bordes superior e inferior. Se añaden únicamente dos hilos
continuos que se encuentran por encima de la marca. No se incluyen los círculos,
anillos punteados ni órbitas de las propuestas descartadas.

`WelcomeConnection` usa un lienzo normalizado 390×844. Primer hilo: empieza en
(78,54), pasa cerca de (254,99) y termina en (390,120). Segundo hilo: empieza en
(185,128), pasa cerca de (282,99) y termina en (390,56). Curvas cúbicas suaves,
trazo 1.15, extremos redondeados y una sombra de 1.5 sigma desplazada 1.2 hacia
abajo. La opacidad de los hilos varía a lo largo del recorrido de 0 a 0.8, con
extremos atenuados; no heredan el 15% de las ondas. Default usa lavanda/coral;
Forest oliva/naranja; Neo claro/verde. Cada persona conserva su recorrido,
y ambos comparten un breve punto de encuentro.

La decoración permanece anclada al fondo, no recibe eventos ni se anuncia a
lectores de pantalla. No hay animación. Los elementos interactivos son widgets,
no una imagen del mockup. El cuerpo pasa de 16/24 a 18/26 para aproximar los tres
renglones del diseño a escala normal en los tamaños de referencia; con texto
ampliado crece y desplaza el contenido naturalmente.

## Temas

| Tema | Fondo | Ondas | Correo | Tinta |
| --- | --- | --- | --- | --- |
| Default | #FFF3E3 | #9FA0FF / #D5E8E6 con transparencia | #D5E8E6 | #302C46 |
| Forest | #F3F6F4 | #7D8D39 / #5B6E2C con transparencia | #E8ECDE | #202A13 |
| Neo | #000000 | #08CB00 / #253900 con transparencia | #253900 | #EEEEEE |

Se reutilizan `RomanzaColors` y los temas Custom existentes. La G de Google
se muestra monocromática en #1F1F1F en los tres temas, sobre superficie blanca neutra, con tinta
#1F1F1F y contorno #B6B8BD. El sobre usa el recurso Lucide local `mail.svg`.
La G mantiene sus proporciones y no adopta los colores de la paleta Romanza.
Referencia de marca: https://developers.google.com/identity/branding-guidelines

## Acciones y alcance

- «Continuar con Google»: mismo `session.google`, deshabilitado durante operación.
- «Continuar con correo»: mismo formulario de registro.
- «Iniciar sesión»: mismo formulario de acceso.
- Progreso, errores, reintentos y avisos: estado existente de sesión.

La edad mínima informativa y los enlaces legales se trasladan al pie de registro
por correo y siguen disponibles en Configuración. Los documentos siguen marcados
como borrador. No se añade aceptación legal ni verificación de edad, ni se cambia
la elegibilidad. El acceso Google conserva el flujo existente; una aceptación
versionada común a todos los proveedores sigue siendo trabajo separado.
No se cambian credenciales, Firebase, reglas, perfil ni rutas privadas.

## Verificación

`test/onboarding_design_test.dart` verifica tres paletas en 390×844 y 412×924,
texto 100% y 200%, navegación correo/acceso/Google y acceso a privacidad desde
registro, además de las pruebas previas de cuenta. La captura opcional usa:

```
flutter test --no-pub --dart-define=CAPTURE_WELCOME=true test/onboarding_design_test.dart
```

Las capturas se escriben en `docs/qa/evidence/welcome-waves/`. Son renders Flutter
con datos falsos, no pruebas de instalación en un teléfono o autenticación real.
