# Continuar desde los conejos hacia Potos

La espada recogida y los enemigos derrotados del jugador se conservan. Todas las pruebas de esta entrega usaron otra instancia, con sus propios guardados. No hay que empezar una partida nueva.

## Referencias y controles

Control F5 retrocede, Control F6 avanza y Control F7 consulta la referencia elegida en casillas. Las salidas aparecen antes que los enemigos. En el bosque hay «Camino al pueblo de Potos por los puentes» y «Regreso a las cascadas». En el río aparece «Entrada al pueblo de Potos», además del regreso al bosque. En Potos aparece el camino de vuelta a las cascadas por el río. Cruzar el paso se hace caminando; las indicaciones directas no evitan árboles ni constituyen una ruta calculada.

La lista también incorpora cofres de recompensa que estén presentes. Desaparecen al perder su presencia o marca de recogible. No se anuncian objetos por la simple muerte de un conejo y no se adivina el contenido de un cofre. La referencia avisa de que puede haber trampa. El perfil de recogibles está limitado a la espada y a estos cofres identificados, no a todos los objetos del juego.

Con el menú del juego abierto, Control F9 permite escuchar y reconocer las señales en la misma guía nativa usada por Chrono. Se impide abrirla en campo libre para evitar pelear mientras se consulta. Control F1 conserva repetir texto; F2 consulta vida/magia y F3 el estado del arma.

## Señales durante el combate

| Señal | Significado |
| --- | --- |
| Dos tonos agudos | Alcance previsto conservador de la espada normal, con la orientación actual. |
| Un tono grave | Objetivo fuera de alcance/alineación o no alcanzable en ese estado. |
| Muestra de peligro de la guía | Mordida nativa dirigida al personaje, o ataque que solapa su cuerpo. |
| Pitido de arma recuperada | La barra de recuperación llegó a cero. |

El radar conserva un objetivo estable; elegir otro conejo con F5/F6 lo cambia explícitamente. Suena con paneo horizontal y mayor cadencia al acercarse. No anuncia direcciones automáticamente por voz. F7 sigue siendo una consulta voluntaria. Los avisos de daño, recuperación y derrota se mantienen.

Las cajas de los doce ataques normales de espada se midieron en esta ROM española. Para dar el tono de alcance se exige que el cuerpo actual del enemigo esté cubierto en algún momento por cada una de las tres variantes normales posibles en esa dirección. Es una previsión conservadora con posiciones actuales: un enemigo puede moverse o esquivar antes de recibir el golpe. La recuperación del arma se anuncia por separado; estar a alcance no significa barra recuperada ni daño máximo. Se silencia la previsión durante el propio ataque, movimientos forzados, menús y escenas, o con otras armas/ataques cargados aún no perfilados. No se anuncia que una pelea será más eficiente sin comprobarla con el usuario.

## Qué se corrigió frente al modelo de Chrono

Se revisaron `rooms/reader.lua`, `rooms/audio-config.lua`, `sound-catalog.lua` y documentación 04 (combate), 18 (bosque) y 79 (choques). Chrono separa proximidad continua, golpe puntual y referencias seleccionables; su combate lee selección de objetivos. Mana mezclaba las muestras direccionales con el choque, cambiaba al enemigo más cercano sin aviso y solo comprobaba el peligro de ese objetivo. Además, el solapamiento del arma del jugador se anunciaba después de empezar a atacar, por lo que no servía como señal previa de alcance.

Ahora el golpe usa `wall_hit.wav` completo en canal 7; las direccionales solo se mezclan para proximidad en canales 8–11. El peligro usa `sign.wav`, sin reutilizar el golpe de pared. Objeto cercano y salida usan canales 12/13; recogida canal 0 y alcance canal 14. No se sobrescribe ninguna DLL ni se limpia globalmente la mezcla al actualizar una pared. Los tonos nuevos son síntesis original de 0,2/0,1 segundos, PCM mono 22050 Hz/16 bits, dedicados a CC0; generador y licencia acompañan los archivos. No requirieron descargas de audio ni reducción con FFmpeg.

## Datos de mapas y objetos

`landmarks.lua` lee cabecera de C87000, lista de eventos C84000, tabla de transiciones C83000 y las casillas actuales de la capa nativa. Comprueba tamaño antes de usar el mapa: 128=896×1312, 129=1024×1152, 130=640×768, 131=832×832. Evita anunciar destinos de otro mapa durante una carga con dimensiones anteriores. Agrupa las casillas que representan el mismo destino y usa la más cercana al personaje. La otra salida del bosque hacia mapa 15 no se etiqueta incorrectamente como Potos: el pueblo es mapa 131, al que se llega por 130.

`pickups.lua` exige actor activo, E1B1=80, nivel 0, vida máxima 0 y clase E1C8 de 0 a 8, sin muerte F9 ni estado ocupado. Esas condiciones proceden de la rutina nativa de recompensas C04203 y la documentación local `rom-combat.md`, sección 13. El actor EA que queda tras una muerte no demuestra por sí mismo que haya cofre. La presencia y posición se leen de nuevo; no se mantiene un historial ficticio de pulsaciones.

Se consultaron también los documentos primarios [recompensas nativas](https://github.com/cidwel/som-decomp/blob/715885595c6917220726d437211a57b58f615fc1/docs/event-vm-chest-reward.md) y [orden de apertura](https://github.com/cidwel/som-decomp/blob/715885595c6917220726d437211a57b58f615fc1/docs/event-party-chest-command.md), guardados en `references/som-decomp`. No se importaron direcciones de Chrono ni fue necesario recurrir a Pokémon Access.

## Pruebas, límites y activación

47 pruebas PASS con Lua 5.1 real: `tests/radar07-model-tests.txt`. Cubren separación del golpe, objetivo estable/selección, mordida de un enemigo distinto del seguido antes de solaparse, alcance al cambiar la orientación, silencio sin voces de dirección, enemigos derrotados, cofres marcados frente a cadáveres, salidas sin enemigos y guía. El mezclador real cargó ambos tonos y se comprobó su canal con volumen cero: eso no es escucha humana.

`profile07d-check/profile.tsv`: PASS de doce animaciones ejecutadas por el motor. Se preparó el registro del personaje y controles a partir de la captura aislada `sword-free.ram`, no de una partida del usuario. Solo para esta medición se controló el resultado de la clase de distancia en C1E418 y la paridad F4, tras comprobar la firma de la ROM. Las cajas capturadas forman `source/sword-boxes.lua`. No hay ese hook ni escrituras de preparación en el lector normal. Tres intentos anteriores quedan registrados: dos no completaron una recogida de espada en el arnés y el tercero no produjo ataques con un pulso demasiado corto y controles incompletos; no cuentan como PASS.

`travel07-check/result.txt`: PASS de cinco transiciones nativas con posiciones preparadas: 128→129, 129→128, 128→129, 129→130 y 130→131. Se eligieron referencias del lector, se situó al personaje sobre sus casillas y se caminó con el motor. Esto demuestra los accesos y destinos; no demuestra recorrer los senderos entre ellos. Coordenadas obtenidas allí: salida 128=(760,824), regreso 129=(248,600), camino a puentes 129=(184,984), entrada de Potos desde 130=(536,504).

Pendientes: escucha con NVDA, combate real del jugador con el radar nuevo, recogida/apertura nativa de un cofre con este perfil y recorridos completos entre salidas. El terreno de 129–131 usa el mismo modelo de capas y pendientes, con dimensiones comprobadas; no se certificaron todos sus bordes ni todos los NPC del pueblo. Las zonas fuera de cobertura anuncian esa limitación al entrar.

No se encontró sesión normal abierta al finalizar, por lo que los cambios se cargarán al próximo inicio con `iniciar-lector.cmd`. No se certifica una recarga en la partida del jugador. Las copias temporales terminaron cerradas. Respaldo anterior: `backups/antes-radar-07.zip`.

Para revertir solo esta entrega, restaurar del respaldo `source/game.lua`, `source/reader.lua`, `source/references.lua`, `source/collisions.lua` y `source/terrain.lua`; retirar los módulos nuevos `radar.lua`, `reach.lua`, `sword-boxes.lua`, `landmarks.lua`, `pickups.lua` y `sound-catalog.lua`. Los WAV nuevos pueden conservarse sin uso. No restaurar ROM, configuración o partidas del jugador.
