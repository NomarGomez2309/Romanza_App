# Validación — bienvenida con ondas

Base: `948738d9b80730869b8b72f8d70e7234912cb6f5` (`Romanza/Dart`).

- `flutter analyze --no-pub`: sin incidencias.
- `flutter test --no-pub --reporter expanded`: 135 pruebas aprobadas.
- Pruebas de onboarding con `CAPTURE_WELCOME=true`: 18 aprobadas; seis renders.
- `git diff --check`: correcto.

Capturas reales de Flutter, inspeccionadas visualmente: Default, Forest y Neo,
390×844 y 412×924, con áreas seguras simuladas. La suite comprueba además texto
al 200%, teclado en cuenta y navegación de los tres accesos; la nueva prueba
abre privacidad desde registro y valida el destino Google con repositorio falso.
No se inició sesión en Firebase real ni se instaló la app en un Pixel físico.

| Tema | 390×844 | 412×924 |
| --- | --- | --- |
| Default | [Captura](evidence/welcome-waves/welcome-default-390.png) | [Captura](evidence/welcome-waves/welcome-default-412.png) |
| Forest | [Captura](evidence/welcome-waves/welcome-forest-390.png) | [Captura](evidence/welcome-waves/welcome-forest-412.png) |
| Neo | [Captura](evidence/welcome-waves/welcome-neo-390.png) | [Captura](evidence/welcome-waves/welcome-neo-412.png) |

Las ondas son curvas vectoriales nativas; las capturas no se empaquetan como UI.
Los colores de proveedores no se alteran con el tema. No hay cambios de backend,
reglas, dependencias o política de edad; los recursos legales siguen siendo borradores.

## Revisión de peso y relieve

La palabra Romanza pasa del eje 500 al 650 de Fredoka. Se conservan tamaño y
geometría. Las ondas incorporan sombras de contacto de sigma 7, bisel interior
difuminado de sigma 5, borde luminoso de 0.8 y gradientes por capa. Son efectos
de pintura estática, aislados en RepaintBoundary; no se aplica blur al texto.
Se regeneraron las seis capturas y se inspeccionaron los tres temas.

Verificación posterior a esta revisión: analyze sin incidencias, 18 pruebas de
onboarding/cuenta aprobadas y diff --check correcto. Las 135 pruebas indicadas
arriba corresponden a la implementación anterior al ajuste de pintura y peso.
No se midió rendimiento en un teléfono físico.

## Revisión de opacidad y proveedor

Trama con opacidad global 0.15, manteniendo el relieve debajo de la composición.
Marca y contenido permanecen opacos. La G se muestra monocromática #1F1F1F
sobre blanco en todos los temas. Se regeneran las seis capturas; se ejecutan
las 18 pruebas de onboarding/cuenta y analyze para esta revisión.

## Ajuste de visibilidad

La revisión al 15% resultó demasiado tenue. Se reduce la transparencia diez
puntos, elevando la opacidad global a 25%; se conserva el relieve y la G
monocromática. Se regeneran las seis capturas y se repiten las 18 pruebas
de onboarding/cuenta.
