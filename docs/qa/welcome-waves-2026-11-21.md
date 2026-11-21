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
