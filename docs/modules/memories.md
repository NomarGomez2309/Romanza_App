# Recuerdos v2

## Objetivo, fuentes y alcance
ESPECIFICACION.md v2.1 y 04_Pantalla.svg. La entrega local muestra vacío real con
acción Preparar una foto; esa acción recupera o crea un borrador, no un recuerdo.
No se presentan fotos de maqueta como datos de usuario ni borradores compartidos.

## Componentes y adaptación
MemoriesScreen, título Fredoka25/32 y estados compartidos. MemoryPhotoCard deja
preparada la representación de foto publicada: ratio175/243, radio16, cover sin
estirar, foto y fecha únicamente, fade inferior; fecha convertida a zona local.
La tarjeta no está conectada a una fuente remota. La grilla con datos, el visor,
la carga/reintento del álbum y acciones de autor requieren el repositorio privado
con identidad; no se presentan como funciones operativas en esta entrega.

## Decisiones confirmadas
- Recuerdos es privado de la pareja, ambos leen y solo el autor elimina.
- Fecha de publicación, más recientes primero, zona horaria del dispositivo.
- Guardar conserva la instantánea hasta completar24h y la entrada de Recuerdos.
- Eliminar una publicación propia elimina ambas entradas y su archivo, con
  confirmación explícita. La expiración por sí sola no borra un archivo guardado.
Estas reglas son contrato para el servidor futuro, no seguridad implementada.

## Pruebas y límites
Vacío y navegación probados en tamaños de referencia, estrecho y texto200%.
Sin sincronización, publicación, expiración de servidor ni pruebas de dos cuentas:
el usuario autorizó explícitamente bloquear esas acciones hasta identidad/vínculo.
