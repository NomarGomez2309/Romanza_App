# Ensayos de auditoría visual

`flutter test tools/qa/visual_audit_test.dart` ejecuta una revisión explícita con
fuentes reales, 12 combinaciones de tamaño/escala y contraste de diálogos.
Actualmente reproduce dos fallos de contraste conocidos (Default y Forest).
No modifica la app ni configura un teléfono. La suite habitual permanece en test/.

Resultados y reproducción manual: docs/qa/visual-audit-2026-11-08.md.
