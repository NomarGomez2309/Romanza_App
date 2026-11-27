# Onboarding y cuenta — propuesta implementada v1

Bienvenida vigente: [ondas e hilos](welcome-waves.md). Este contrato cubre
formularios, perfil y cuenta.

Base exacta: `53b9743f122890ebfac1a7968741560af06431a5`, rama `Romanza/Dart`.
Se reutilizan el repositorio de autenticación, controlador de sesión, logo SVG,
Fredoka/Nunito locales, iconos Lucide/Romanza, paletas y rutas de ese commit.
No se incorpora la arquitectura diferente de `main` ni se reemplaza el dashboard.

## Experiencia visual

- Acceso/registro/recuperación: título breve, símbolo en superficie suave,
  explicación y campos separados. Se conservan Google, correo, confirmación de
  contraseña, validaciones, mensajes y recuperación oficiales de la base.
- Verificación: correo propio legible, botón de comprobación y reenvío con el
  cooldown existente. Se conserva la alternativa «Usar otra cuenta».
- Perfil: los usuarios verificados cuyo perfil no tenga nombre completan
  «¿Cómo te llamas?» antes de entrar. Un nombre del perfil ya existente,
  incluido el creado por Google en la base, no vuelve a solicitarse.
- Cuenta: avatar propio o fallback neutro, edición del nombre visible, correo
  propio, estado de verificación del correo y proveedores existentes. Para
  cuentas con proveedor contraseña hay acceso al restablecimiento oficial.
  No se crea un método de acceso nuevo ni se vinculan proveedores desde esta UI.

No hay carrusel obligatorio, animaciones continuas, rachas ni solicitud anticipada
de cámara/notificaciones. La edad mínima de 18 y los documentos marcados como
borrador se conservan exactamente del commit base. Esta entrega no añade
comprobación de edad, consentimiento ni documentos legales finales.

## Geometría y lenguaje común

Unidades lógicas; referencias de prueba: 390×844 y 412×924.

| Elemento | Geometría / tipo |
| --- | --- |
| Contenido de acceso/cuenta | Ancho máximo 480; margen lateral 24; vertical 16; áreas seguras reales |
| Marca | Logo existente + Fredoka 24/32, peso variable 600 |
| Títulos de paso/cuenta | `RomanzaType.greeting`: Fredoka 34/40, peso 600 |
| Explicaciones | Nunito 16/24, color secundario del tema |
| Símbolo de paso | Superficie 72×72, radio 24, icono 30 |
| Campos | Radio 18; padding 18; línea de foco 2; errores de hasta 3 líneas |
| Acción principal | Alto mínimo 56, radio 20, Nunito 16/700; crece con texto |
| Avatar de cuenta | 80×80, radio 28; foto del proveedor o fallback Lucide |
| Tarjeta de acceso | Radio 24 y padding 20; texto y etiquetas adaptables |

El panel inferior existente conserva su geometría, blur20.52, tintes, avatar propio
46 y secundario27.6, texto y las cinco opciones aprobadas. El destino `Cuenta`
ahora abre el editor real. `Temas`, Custom Duo, `Mi Pareja`, idioma y borradores
legales mantienen sus claves y comportamiento del commit de partida.

Los colores vienen de `RomanzaColors`; no se añaden colores fijos para una paleta
ni fuentes/iconos externos. No se modifican fotos con el tema. Los márgenes del
onboarding/cuenta son nuevos tokens de composición funcional; no cambian los16
puntos del dashboard ni las cotas del panel existente.

El contenido puede crecer y desplazarse. El encabezado se reorganiza con Wrap,
los botones tienen altura mínima, los campos admiten errores multilínea y el
teclado reduce el espacio disponible. No se reduce el tamaño del texto para
hacer caber un paso. Los símbolos decorativos quedan fuera de la semántica;
formularios y estados conservan etiquetas y regiones de aviso.

## Datos y navegación

`AuthRepository` añade `readName` y `saveName`. La implementación Firebase lee
`users/{uid}.name` del propietario verificado. Al guardar escribe exclusivamente
`name` y `updatedAt` con timestamp de servidor; usa las reglas ya existentes,
sin desplegarlas ni ampliarlas. Se recortan espacios externos del nombre, nunca
de la contraseña. El límite de100 caracteres coincide con la validación existente.
Este campo es un nombre visible, no un nombre de usuario único ni una reserva
sobre `usernames`/`accountProfiles`.

`SessionController` añade el estado `profile`. Tras verificar y preparar el perfil,
consulta el nombre. Si falta, ofrece el paso de nombre; si existe, continúa al
Inicio. Un guardado confirmado evita volver a pedirlo en el próximo arranque.
Una lectura fallida conserva la identidad y muestra el error de carga/reintento.

La lectura tiene límite de20s y el guardado sin confirmación informa a los20s.
Un timeout no cancela una escritura que ya haya llegado a Firestore: no se
presenta como una reversión ni como confirmación de guardado. Reintentar el mismo
nombre es idempotente. Durante una operación se deshabilitan envíos repetidos;
un fallo conserva el texto escrito. El resultado de otra generación/UID no
sustituye los datos de la sesión actual.

`SessionScope` proporciona el mismo controlador a las rutas privadas. El editor
no crea otro usuario ni conserva credenciales. Cambiar UID, salir o dejar de estar
autenticado destruye el navegador privado existente, incluido el editor. El campo
no se reinicializa en cada rebuild del tema: conserva el borrador al escribir.
El nombre se carga al entrar/restaurar la sesión y se actualiza en este editor;
no se implementa sincronización de conflictos entre editores de otros dispositivos.

El correo y los proveedores se consultan en Firebase Auth, y la foto conserva
el origen del proveedor. No hay subida ni editor de foto nuevo. No se modifican
campos de pareja, consentimiento, edad, tokens, contraseñas ni documentos de otra
persona. Configuración sigue diferenciando carga, sin vínculo y error.

## Archivos y evidencia

- `lib/features/auth/auth_design.dart`: composición y controles comunes.
- `auth_screens.dart`: bienvenida, formularios y verificación.
- `profile_setup_screen.dart`: paso de nombre.
- `session_scope.dart`, `session_controller.dart`, `auth_gate.dart`: perfil y rutas.
- `lib/features/settings/account_screen.dart`: editor y acceso propio.
- `settings_sheet.dart`: destino Cuenta; resto del panel conservado.
- `test/onboarding_design_test.dart`: flujo de nombre, edición/error, cambio de
  cuenta, cierre de sesión, 3paletas×2anchos×2escalas y teclado elevado.

Capturas generadas por los widgets Flutter con datos de prueba, no imágenes
aplanadas usadas como interfaz ni evidencia de instalación:

- [Registro Default 412](../qa/evidence/onboarding-v1/register-default-412.png)
- [Nombre Forest 390](../qa/evidence/onboarding-v1/profile-forest-390.png)
- [Cuenta Forest 390](../qa/evidence/onboarding-v1/account-forest-390.png)
- [Panel existente Forest 390](../qa/evidence/onboarding-v1/settings-forest-390.png)

Los nombres y correos `.invalid` de estas capturas son fixtures exclusivos de
pruebas. La aplicación no usa esos datos como valores predeterminados.

## Verificación y pendientes

```bash
flutter analyze --no-pub
flutter test --no-pub --reporter expanded
flutter test --no-pub --dart-define=CAPTURE_DESIGN=true test/onboarding_design_test.dart
```

Las pruebas usan repositorios falsos para no crear ni modificar cuentas reales.
No sustituyen una prueba con Firebase de desarrollo ni con Pixel físico. No se compiló APK ni se instaló en un Pixel durante esta entrega.
El inicio de sesión real, recepción de emails y guardado real del nombre deben
revisarse en un proyecto de pruebas antes de publicar esta rama.

No hay despliegues Firebase ni cambios de reglas, políticas o publicación en
tiendas en esta entrega. La vinculación, aceptación legal versionada, comprobación
de edad, subida/edición de foto y eliminación de cuenta siguen fuera de este cambio.
