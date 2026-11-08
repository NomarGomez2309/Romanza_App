# Módulo de arranque

Inicializa Firebase y carga la preferencia local de paleta. Durante la espera
muestra progreso con etiqueta semántica; ante error de Firebase, estado compartido
con Reintentar. Tras éxito abre Hoy. Un fallo de preferencias conserva Default
y muestra el problema al abrir Usuario. Inicializar Firebase no prueba acceso
remoto ni conexión de pareja. Se mantienen las pruebas de espera y reintento.
