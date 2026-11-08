# Arquitectura

El producto activo es Flutter, por decisión del usuario. Las instrucciones
anteriores relativas a Compose/Kotlin dejan de describir la implementación.

- `lib/main.dart`: enlace entre configuración Firebase y aplicación.
- `lib/app.dart`: ciclo de inicialización, carga, error/reintento y pantalla mínima.
- `lib/firebase_options.dart`: configuración previa conservada; ver límites en README.
- `legacy/flutter/`: prototipo previo, sin importaciones desde la aplicación activa.

No se realizan llamadas externas en build. La inicialización se ejecuta una vez
por estado de aplicación y solo se repite con reintento explícito tras error.
No hay todavía datos de negocio, persistencia propia ni conexión de pareja.
Las futuras funciones separarán presentación, estado, contratos y servicios.

Se mantienen las versiones existentes de Firebase y Google Sign-In. Se retiran
las dependencias directas de Spotify/OAuth web, fuentes y enlaces externos, así
como los iconos Cupertino no utilizados. HTTP queda como dependencia transitiva.
