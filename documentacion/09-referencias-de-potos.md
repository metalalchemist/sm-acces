# Orientación en Potos

Si acabas de llegar, selecciona «Viejo» con Control F5/F6 y consulta su posición con Control F7. Acércate caminando hasta él: el diálogo de la plaza se activa por contacto y continúa la historia. No hace falta golpearlo con B. La referencia avisa de que inicia una escena. Las indicaciones son dirección directa en casillas, no una ruta entre edificios.

## Referencias nuevas

En el exterior aparecen el Viejo, Timothy y los habitantes con conversación que estén presentes, además de Tienda, Posada, Casa del Viejo, Casa del oeste, Casa del sur, salida sureste y regreso por el río hacia las cascadas. Las personas siguen sus posiciones actuales y desaparecen del selector si el motor las retira. Los actores de escena sin conversación no se presentan como personas utilizables.

La tienda y dos casas comparten el mapa interior 257, pero tienen transiciones distintas: 89, 88 y 91. El selector las mantiene separadas. Casa del Viejo es transición 90/mapa 258, y Posada es transición 92/mapa 259. En cada sector interior se muestran sus personas pertinentes y el regreso al pueblo. Las escaleras de la casa del Viejo distinguen el sótano de la planta principal; no se propone la salida de otra sala como si estuviera accesible desde el sótano.

Para conversar con las demás personas, acércate, mira hacia ellas y pulsa B. El sonido de persona cercana usa la muestra existente `person.wav`, ID 14/canal 16, con paneo y volumen por proximidad; se prioriza la persona seleccionada, o la de referencia si no se seleccionó ninguna. Se suspende sin control de campo, en menús y escenas. Control F9, con menú abierto, incluye su muestra.

## Datos verificados

Los destinos se leen de las casillas y tablas nativas. Los NPC se reconocen por su evento local en actor+3E, no por estadísticas de enemigos. La captura real de llegada muestra:

| Conversación | Evento | Identidad de referencia |
| --- | --- | --- |
| Continúa la escena de la plaza | 10C, palabra 210C | Viejo, por contacto |
| «Rápido» | 10E | Timothy |
| Conversaciones locales | 107, 108, 109, 10B | Habitantes de Potos |
| Comercio | 300 | Comerciante del sector de tienda |
| Posada | 320 | Posadero |

El byte E1E7 de los NPC de esta captura es cero; no es una identidad de conejo en este contexto. La rutina normal C0D1FE recorre actores desde desplazamiento 0600 hasta antes de 1800. Se limitó a slots 3..11 la búsqueda de personas y recompensas; continuar más allá podía interpretar RAM del terreno como actores.

Las salidas de las casas 257 usan el atributo nativo de retorno; la posada y la casa del Viejo tienen transiciones explícitas de regreso. No se mezclan estas últimas con puertas de otras salas del mismo mapa. Posada: punto de salida observado (328,280). Casa del Viejo: (824,296), no la puerta (504,328) de otro sector. Son coordenadas internas; al jugador se le indican casillas.

## Evidencia y límites

56 pruebas PASS de Lua 5.1 real: referencias desde RAM nativa, selección inicial del Viejo, puertas distintas para el mismo destino, posición viva, desaparición, origen/sector de interiores, salida correcta y contacto sin instrucción equivocada de B. Se mantienen las pruebas anteriores de combate, maleza, menús y audio.

`tests/potos09b-check/result.txt`: PASS. Se prepararon posiciones en una copia independiente y el motor procesó las cinco entradas, sus cinco regresos y el contacto con el Viejo. Su texto inicial fue capturado por el lector. Esto no demuestra caminar todos los senderos entre puntos; no hubo movimientos en la partida del usuario. Arnés, fixture y módulos ejecutados se conservaron en `frozen/`, con hashes en `frozen-inputs.json`.

Se conservaron intentos previos. La investigación inicial tuvo un error de sintaxis del arnés, corregido antes de obtener la captura útil de llegada. `potos09-check` detectó ausencia de regreso en la posada y la orden incorrecta de pulsar B al Viejo; también reveló que el retorno elegido en su casa pertenecía a otra sala. El nuevo modelo usa la transición explícita correcta, identifica la conversación por contacto y se volvió a ejecutar en `potos09b-check` sin fallos.

No se han validado compras, pago/descanso/guardado de la posada, todas las conversaciones, abrir el cofre del sótano ni el combate que sigue a la escena. Las escaleras se identificaron en las tablas y su separación se modeló, pero no se recorrieron nativamente. Los menús de servicios no se declaran completos por haber identificado a su encargado. La proximidad de paredes conserva su cobertura exterior 128–131; los interiores nuevos conservan el golpe de choque nativo y las referencias, sin certificar todavía todas sus paredes.

No se encontró sesión habitual abierta para recargar: se carga al próximo inicio del lector. Las copias temporales se cerraron; ROM y partidas habituales no se restauraron ni se cargaron.

## Reversión

Respaldo anterior: `backups/antes-potos-09.zip`. Para revertir solo esta entrega, restaurar `source/landmarks.lua`, `source/game.lua`, `source/reader.lua`, `source/sound-catalog.lua` y `source/pickups.lua`, y retirar `source/village.lua`. No restaurar ROM, partidas ni configuración del jugador.
