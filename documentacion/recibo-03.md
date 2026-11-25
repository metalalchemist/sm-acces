# Recibo 03: colisiones y recogida de espada

Se implementaron avisos direccionales de terreno rechazado y se corrigió la recuperación de rutas agotadas. El inventario y la escena de recogida de espada conservan su comportamiento y sonido. No hubo navegación automática en modo de juego.

## Evidencia

- 29 pruebas del módulo real en Lua 5.1: PASS, `tests/walls03-model-tests.txt`. Incluyen retorno temprano, actor por contexto en vez de X, reposo, corriente, compañero, escena, ataque, repetición y reinicio de la ruta tras excluir pasos.
- Caso aislado `walls03-check`, desde inicio nuevo y botones nativos: el personaje pasa de posición Y inicial a detenerse en Y=538 contra roca. La caminata corta posterior desde la base permite avanzar. Recibo final `idle=0 blocked=1 walk=0 loaded=true`, con mezclador real silenciado. `loaded=true` señala base anónima propia guardada en memoria; no señala carga del archivo del jugador.
- Ensayo anterior con reloj por frames, sin mezclador: tres señales de pared mientras se insistía, cero al estar quieto y cero en caminata libre. Conservado en los segmentos de arranque de `reader.log` del caso. Producción usa reloj monótono; no comparar cantidades como si ambos ensayos duraran el mismo tiempo real.
- PCM no nulo en los primeros 3969 frames de cada WAV direccional. Las muestras existentes permanecen intactas; el mezclador limita la emisión a 180 ms. No se descargaron sonidos externos ni se atribuyó dominio público a los WAV locales.
- Recarga Lua aislada confirmada por entrada nueva de START, sin reinicio ni carga de ROM. No se sobrescribieron DLL. El módulo usa memoria nativa solo desde el hilo del emulador.

## Investigación conservada

La primera comparación antes/después del terreno no detectaba el rechazo temprano, que devuelve el control sin llamar a la aplicación de posición. Además, la rutina de límite del grupo deja X sobre el último compañero: el contexto del movimiento está en DP10. Los registros nativos mostraron X=0400 y DP10=0000 al mover al protagonista. Se corrigieron ambos puntos antes de afirmar que funcionaba el aviso.

Los primeros intentos de arrancar/cargar una copia de estado no llegaron al ensayo. Se conservan sus metadatos de sesión; el resultado del caso se sustituyó al repetir la prueba y no se presenta el intento fallido como validación nativa. Se mantuvo el gestor abierto con WaitForExit y se ejecutó el recorrido de inicio nuevo. El archivo copiado nunca se cargó sobre la sesión normal del usuario.

Una captura directa de la copia normal no se obtuvo porque ya había cerrado al ejecutar la comprobación de su PID. El último registro orientaba desde el oeste de la espada. El archivo privado copiado tenía mapa 128, X=425, Y=928, historia=0; no es una ubicación en vivo posterior. Estar a unas cinco casillas de la espada explica que el localizador suene sin que B pueda interactuar; la recogida validada requiere cercanía por el norte y mirar al sur.

## Protección y entrega

Pruebas únicamente en `tests/emulator/snes9x.exe`, con PID y hora registrados por el gestor en sesiones. Su cierre final conserva los archivos del caso. El lector normal no pulsa botones. `estado-actual.txt` es un diagnóstico de lectura fechado, no un guardado.

Se verifica la ROM y el inventario protegido de origen con `investigar.py`. La copia del archivo `game.oops` puede contrastarse con el original por SHA-256; no se restauró ningún archivo de `partidas/`. Respaldo previo `backups/antes-colisiones-03.zip`; entrega `backups/colisiones-03.zip`, con inventario SHA-256. La reversión de código está limitada a la fuente y entrada de esta unidad, conservando partidas y entregas previas.

La prueba silenciada no sustituye a escuchar los avisos con NVDA/control. Si no existe copia normal abierta al terminar, el aviso se activa al siguiente inicio del lector. Si sigue abierta, usar únicamente la recarga propia verificada y confirmar START antes de anunciar activación.
