# Documentación vigente de Romanza

Consolidada el 27 de noviembre de 2026. Empezar por el [sistema visual](design-system.md).
Las guías de módulos describen el diseño actual; los informes QA registran pruebas
fechadas y no sustituyen los contratos visuales. Una propuesta pendiente no equivale
a funcionalidad implementada. [Registro de limpieza](qa/documentation-cleanup-2026-11-27.md).

## Diseño y recursos

- [Sistema visual, paletas, tipografía y medidas](design-system.md)
- [Hoy](modules/today.md)
- [Bienvenida con ondas e hilos](modules/welcome-waves.md)
- [Acceso, perfil y cuenta](modules/onboarding-account.md)
- [Configuración](modules/settings.md)
- [Temas y Custom Duo](modules/preferences.md)
- [Cámara 1:1 y flash](modules/camera-v4.md)
- [Planes](modules/plans-ui.md)
- [Recuerdos, colecciones y visor](modules/memories-grid.md)
- [Fechas importantes y propuesta de widget](modules/important-dates.md)
- [Navegación flotante](modules/floating-navigation.md)
- [Iconografía y licencias](modules/iconography.md)

Capturas vigentes en `qa/evidence/`: bienvenida en `welcome-waves/`; dashboard y
widget en `important-date/`; navegación en `navigation/`; planes en `plans/`;
recuerdos en `memories/`; formularios y cuenta en `onboarding-v1/` (el nombre de la
carpeta no convierte su antigua bienvenida en vigente: esa captura se retiró).
Las fotos y ocasiones de pruebas no son datos de cuentas reales.

## Ingeniería y validación

- [Arquitectura](architecture.md)
- [Integración de ramas y entradas](qa/branch-integration-2026-11-21.md)
- [Base segura experimental](secure-core.md)
- [Estado y pendientes](roadmap.md)
- [Arranque](startup-ui.md)
- [Validación actual y límites](validation.md)
- [Plantilla de módulo](templates/module-ui.md)

Las capturas de instalación del launcher y los informes QA históricos se conservan
como evidencias técnicas fechadas. No se usan para extraer radios, paletas o
composiciones actuales. Las referencias sustituidas se recuperan mediante Git;
no hay una segunda especificación visual antigua dentro del índice activo.
