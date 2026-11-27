# Sistema visual vigente de Romanza

Consolidado el 27 de noviembre de 2026 contra `Romanza/Dart`, base `846c096a`.
Esta guía y los contratos enlazados sustituyen las medidas antiguas de documentos
v1/v2. El código de los componentes citados es la referencia de implementación.
No se deducen medidas de un mockup generado ni se aplican de nuevo porcentajes
históricos de ajuste.

## Identidad

Romanza combina conexión emocional y herramientas cotidianas para parejas.
El diseño es cálido, juvenil, suave y funcional. Sin neobrutalismo, sombras negras
desplazadas, contornos de construcción ni adornos que compitan con las fotos.
Se mantienen Fredoka y Nunito locales con sus licencias, Lucide y las variantes
Romanza. La paleta Neo no cambia ese lenguaje.

## Paletas vigentes

| Paleta | Colores base |
| --- | --- |
| Default, inicial | #9FA0FF · #D5E8E6 · #FFF3E3 · #FF7171 |
| Forest | #F3F6F4 · #7D8D39 · #5B6E2C · #FF5A22 |
| Neo | #08CB00 · #253900 · #000000 · #EEEEEE |

`RomanzaColors` asigna los roles y sus variantes legibles. En Forest, secundario
#4D5E26 y sobre primario #111A08; no usar blanco pequeño sobre #7D8D39.
Las fotos conservan sus colores. Custom personal es local; Custom Duo todavía
no sincroniza acuerdos de pareja. Ver [Temas](modules/preferences.md).

## Tipografía

| Uso | Fuente | Tamaño / línea | Peso |
| --- | --- | --- | --- |
| Romanza en bienvenida | Fredoka | 26 / 32 | 650 |
| Titular de bienvenida | Fredoka | 40 / 44 | 600 |
| Saludo y título principal | Fredoka | 34 / 40 | 600 |
| Sección | Fredoka | 25 / 32 | 600 |
| Tarjeta | Fredoka | 16 / 20 | 500 |
| Contador | Nunito | 15 / 20 | 400 |
| Cuerpo | Nunito | 14 / 20 | 400 |
| Tiempo | Nunito | 12 / 16 | 400 |
| Navegación flotante | Nunito | 12 / 16 | 700 |

Las variantes de formulario, panel, mes y widget se detallan en sus contratos.
Respetar el texto del sistema; crecer, reorganizar o desplazar el contenido.

## Medidas comunes

Unidades lógicas. Referencias: iPhone 14 390×844 y Android/Pixel 9 412×924;
no son resoluciones físicas obligatorias ni insets fijos.

| Elemento | Medida vigente |
| --- | --- |
| Margen del dashboard y biblioteca | 16 |
| Ancho máximo de páginas | 552 |
| Acceso/cuenta | Margen 24, ancho máximo 480 |
| Encabezado de Inicio | Fila 72; símbolo 41.6×29.25 |
| Perfiles unidos de Inicio | Diámetro 41.6; grupo 76.7; unión 15.6; corazón 11.05 |
| Instantáneas de Inicio | Dos columnas; gap 8; ratio ancho/alto 0.86; radio 16 |
| Añadir instantánea | Visual 52×44; radio 14; toque 52×48 |
| Nota / plan de Inicio | Radio 16; fondos trébol / hexágono solo en insignias |
| Miniatura de recuerdo en Inicio | 80×52; radio 12 |
| Cámara y confirmación | Ratio 1:1; radio 20; disparador 74 |
| Biblioteca de Recuerdos | Foto 1:1, radio 16, gap 6; 3 o 2 columnas |
| Meses, años y colecciones | Radio 24 |
| Barra flotante | Radio 36, inset 6, selector radio 30; cápsula normal 76 |
| Configuración | Radio superior 24; blur 20.52; tinte .77; borde blanco .253 |
| Cuenta dentro de Configuración | Mínimo 104; radio 20; avatares 46 / 27.6 |
| Tarjeta de fecha próxima | Radio 24; padding 16; bloque 84×84, radio 20 |
| Widget de fecha, propuesta | Cuadrado de referencia 180×180; radio 28 |

La barra y las tarjetas crecen con texto grande. SafeArea y MediaQuery proporcionan
las áreas seguras reales. Los controles de acción tienen área táctil mínima 48;
los azulejos de fotos se adaptan a la densidad documentada en Recuerdos.
No usar el antiguo avatar 64/grupo118, ancho máximo520, barra72/pastilla80×56
ni fotos de biblioteca 175/243 como contrato del diseño actual.

## Contratos por pantalla

- [Hoy](modules/today.md): estructura y estados del dashboard.
- [Bienvenida](modules/welcome-waves.md): ondas al 15%, hilos, wordmark y Google monocromo.
- [Acceso y cuenta](modules/onboarding-account.md): formularios, verificación y perfil.
- [Configuración](modules/settings.md): resumen de cuenta, Temas y Mi Pareja.
- [Temas](modules/preferences.md): cuatro opciones visuales y Custom Duo.
- [Cámara](modules/camera-v4.md): captura directa 1:1, flash, sin galería.
- [Planes](modules/plans-ui.md): Día y Calendario, borradores de sesión.
- [Recuerdos](modules/memories-grid.md): biblioteca, meses, años, colecciones y visor.
- [Fechas importantes](modules/important-dates.md): ventana de siete días y propuesta de widget.
- [Navegación](modules/floating-navigation.md): selector, relleno y movimiento.
- [Iconografía](modules/iconography.md): catálogo y licencias.

## Alcance real

Las capturas de prueba no representan datos predeterminados de usuarios.
La autenticación y edición del nombre tienen su propio contrato. Invitaciones,
publicación privada, expiración remota, borrado por autor, widgets nativos y
consentimientos versionados requieren sus integraciones; el aspecto no certifica
su seguridad. Las propuestas de Espejo y onboarding futuro no reemplazan
automáticamente el flujo implementado.
