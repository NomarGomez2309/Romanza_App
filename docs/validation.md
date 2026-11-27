# Validación de Romanza

Esta guía se revisó durante la limpieza documental del 27 de noviembre de 2026.
La limpieza no cambia la app ni repite pruebas de ejecución sin cambios de código.

## Último cierre registrado

[Fechas importantes](qa/important-dates-2026-11-22.md): 241 pruebas Flutter
aprobadas y análisis sin incidencias. Incluye texto 100/200%, layouts 320/390/412,
tres temas, selección de fechas, movimiento y reducción de movimiento.
El modo de capturas del módulo aprobó49 pruebas; sus imágenes son renders Flutter.
Estos resultados corresponden al código de esa entrega, no una instalación nueva.

## Informes por área

- [Autenticación](qa/authentication-2026-11-21.md)
- [Formularios y cuenta](qa/onboarding-account-2026-11-21.md)
- [Bienvenida](qa/welcome-waves-2026-11-21.md)
- [Cámara y flash](qa/camera-v4-2026-11-10.md)
- [Iconografía](qa/iconography-2026-11-12.md)
- [Navegación](qa/floating-navigation-2026-11-22.md)
- [Planes](qa/plans-ui-2026-11-22.md)
- [Recuerdos](qa/memories-grid-2026-11-22.md)
- [Icono y nombre de instalación](qa/launcher-pixel-2026-11-15.md)

Cada informe conserva su fecha, dispositivo o entorno y límites. Los resultados
antiguos no certifican funcionalidades añadidas después. Las comparativas visuales
sustituidas se retiraron del catálogo; no se borran licencias ni pruebas de seguridad.

## Comandos de referencia

```
flutter analyze --no-pub
flutter test --no-pub
```

La app normal requiere su configuración Firebase. Las vistas visual_preview y los
tests no prueban operaciones de cuentas reales. TalkBack/VoiceOver, ejecución iOS,
servicios entre dos cuentas, publicación, expiración y widgets nativos requieren
validación específica. Ver [estado y pendientes](roadmap.md).
