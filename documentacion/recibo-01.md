# Recibo 01: lector, espada y conejo

La unidad añade un lector experimental, su lanzador independiente y pruebas. Identidad de ROM en `evidence/rom-identity.json`. No se modificó la ROM ni se usó una partida del jugador para investigar.

## Resultados

| Capa | Ensayo | Resultado y evidencia |
| --- | --- | --- |
| Módulo real en Lua 5.1 | `tests/test_reader01.py`, con `python` y unittest | 18 pruebas, PASS; `tests/reader01-tests.txt` |
| Texto y selección nativos | Caso `boot-reader01-check`, `native-bootstrap.lua` | 2400 frames, inicio sin guardados, C y CB escritos y confirmados, prólogo leído. `bootstrap-result.txt`, RAM/GD y log del caso |
| Espada | Caso `reader01-check`, B desde el norte del actor D8 | `CF10` 0→1, actor activo 1→0; recogida en segmento nativo del log. `sword-before`, `sword-after-300`, `sword-collected` |
| Rueda | Y abre, arriba cambia categoría, derecha mueve selección | Espada→opciones→Ventana; Y cierra, A ensayada no cerró. Capturas `ring-*` |
| Recorrido del motor | Entradas nativas sin RAM inyectada | Corte de maleza y transición 128→129; `workbench.tsv`, `forest-entry`, `rabbit-before-dialog` |
| Combate nativo | `fight-rabite.lua`, presupuesto 2400 frames | Conejo 20→0 HP, personaje 50→50. Primera evidencia preservada en `evidence/reader01/rabite-first.txt` y TSV; repetición en el caso |
| Daño entrante | `receive-rabite.lua`, sin ataques del jugador | Personaje 50→46; amenaza geométrica en frame 299, daño y anuncio en 302. `rabite-incoming.txt`, captura y log |
| Geometría | Capturas reales y modelo del módulo de producción | Caja de espada `(16,-26,32,32)` fijada en fixture; exclusión de cuerpos vacíos y planos distintos. No garantía de impacto |
| Voz/audio | Inicialización nativa sin emitir voz de prueba; WAV y mezcla a ganancia cero | Prism encontró NVDA. Item: 7277 frames PCM, pico 7822. `workbench.tsv` registra carga y llamada de mezcla |
| Valoración humana | No ejecutada | Pendiente escucha con NVDA/control y utilidad de las señales |

## Intentos y límites conservados

El hook de apertura no observaba todos los cambios del nombre. Se añadió el manejador nativo por fotograma `C020A7` y se comprobaron letras A/B/C y nombre CB con botones. Cargar permanecía en Empezar porque `A215=FF` indica ausencia de guardados; las primeras aserciones esperaban una selección que el motor deshabilita. Fallos archivados en `evidence/reader01/bootstrap-*-fail.txt`; no se inyectó RAM para inventar una selección disponible.

Una prueba de caja dependía de la animación final de una pelea, que cambia al repetir el ensayo. Se fijó `tests/fixtures/reader01/rabbit-swing.ram` y se comprobó su caja concreta. Los tests de modelo escriben desde entonces a `tests/model01-check`. La parte antigua del log de campo contiene entradas de modelo anteriores a esa separación; la recogida nativa se delimita por su arranque del lector y las capturas.

Las rutas automáticas de investigación se corrigieron tras choques reales y escenas. Nunca se cargan en juego normal. La ruta pasiva de producción solo tiene comprobaciones con RAM capturada; no se ha demostrado un recorrido completo guiado por oído. El combate automatizado del arnés prueba acciones del motor, no jugabilidad humana. El radio de radar no se presenta como alcance garantizado del arma.

## Integridad, procesos y activación

La sesión de campo usó exclusivamente `tests/emulator/snes9x.exe`: PID histórico 2392, inicio `639306386847850235`, caso `reader01-check`. Los arranques posteriores tienen identidades archivadas en `boot-reader01-check/sessions/`. El gestor comprueba propietario, ruta, PID y hora para cerrar; no operar PID históricos por número.

SRAM, estados, capturas y configuración de cada prueba están en su caso. La copia normal usa `player/`, con partidas propias en `partidas/`; el lanzador conserva el mando y verifica el SHA-256. Los controladores de prueba no se cargan en modo de juego.

Inventario protegido de origen: 14 archivos. Verificación final en `evidence/integrity-after.json`. Activación y PID de la copia normal, si se inició, se registran en `evidence/reader01/activation.txt` y `reader.log`. Los estados preparados durante investigación no se copian a las partidas de juego.

La copia normal inició con backend NVDA y dejó un arranque nuevo en el log. Posteriormente se observó su cierre normal (`STOP Mana reader`); no se deja como activación actualmente abierta. El menú de entrada en segundo plano no confirmó su marca en ese ensayo. Se separó su auxiliar del gestor de pruebas y se evitó repetir una orden de alternancia cuando la interfaz no refresca la marca. Ese último ajuste del auxiliar solo tiene validación estática; falta confirmar su marca en una próxima sesión normal. El lector y los botones de nombre sí aparecen en el registro de esa sesión. Si el mando no responde, activar la ventana es el procedimiento documentado.

Respaldo previo `antes-lector-01.zip`; entrega `lector-01.zip`, inventario SHA-256 en `evidence/backup-lector-01.json`. Excluye ROM, SRAM y binarios del emulador. Los WAV/DLL se copian sin modificar originales de Chrono; no se sobrescribió ninguna DLL cargada. `tools/` está ignorado por Git, por lo que estos respaldos son archivos reales.

Reversión: cerrar la copia normal identificada y dejar de usar `iniciar-lector.cmd`; conservar `partidas/`. La unidad está dentro de `SM access`. No restaurar ROM, partidas ni configuración de Chrono.
