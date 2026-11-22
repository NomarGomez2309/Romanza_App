# Integración de ramas — 21 noviembre 2026

Destino: `Romanza/Dart`. Orígenes:

- `feat/welcome-waves-themes`, `c69b0180`: integrada mediante avance directo.
- `feat/onboarding-design-53b9743f`, `b6c98af0`: ya integrada por PR #8.
- `feat/secure-session-foundation`, `6dd1076d`: fusión con resolución explícita
  de los conflictos de arranque, documentación, reglas y dependencias.

Se conserva `Romanza/IOS`, así como los guardados temporales de GitHub Desktop.
No se reescribe historia ni se fusiona `main` hacia la aplicación visual.

## Resolución funcional

El arranque habitual conserva bienvenida, acceso, perfil editable, temas y
dashboard existentes. Se incorpora el timeout de inicialización de la base segura.
`RomanzaApp.homeBuilder` permite probar la otra entrada sin construir el
repositorio de la aplicación habitual antes de inicializar Firebase.

La base segura no puede sustituir silenciosamente a la actual: espera perfiles
con `displayName`, consentimientos y relaciones del servidor, mientras la app
visual usa perfiles con `name`. Se conserva como `lib/secure_main.dart`, con sus
servicios, controlador, pantallas y pruebas. No se presenta como funcionalidad
activada en el dashboard ni se efectúa una migración de cuentas.

Se separan sus reglas originales (sin cambios de permisos) en
`backend/firestore.rules` y su configuración en `firebase.secure.json`.
La prueba del backend y sus instrucciones apuntan a esos archivos. El archivo
de configuración habitual conserva el despliegue existente. Se unen las
dependencias y se regeneran los registros de plugins mediante Flutter.

## Validación

- 40 pruebas de arranque, autenticación, onboarding/cuenta y controlador de
  sesión aprobadas. Incluyen timeout/reintento y aislamiento de las entradas.
- Análisis de `lib` y `test`: sin incidencias.
- Comprobación del diff preparado: sin errores de espacios ni conflictos.
- Reglas de la base segura preservadas respecto al origen (comparación del
  contenido normalizando saltos de línea).
- Compilación Android debug aprobada con las dependencias combinadas.
  Advertencia de metadatos del SDK del entorno; no impidió generar el APK.

No se ejecutaron los emuladores del backend: sus dependencias Node no están
instaladas en este entorno. No se sustituyeron las pruebas existentes por mocks
del servidor. No se despliega Firebase ni se instala en el Pixel como parte de
esta organización de ramas.
