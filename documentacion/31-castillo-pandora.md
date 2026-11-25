# Salas interiores del castillo de Pandora

Control F5 y Control F6 seleccionan la referencia anterior o siguiente. Control F7 consulta dirección, distancia en casillas de 16 píxeles e instrucciones. Consultar conserva la selección; no calcula rutas, descarta pasos ni mueve al personaje. La dirección directa puede atravesar obstáculos. La selección deja de estar disponible cuando desaparece su persona o cofre.

Se incluyen vestíbulo y ala este, galería superior, pasillo del trono, sala de soldados, cocina, salón del trono, sala de Elman, habitación del rey y sala del tesoro. Los mapas compartidos se filtran por dimensiones, procedencia, entrada y sector actual; regresar de la cocina cambia el sector aunque conserve mapa y entrada.

Las personas se identifican por tipo y evento nativos, con presencia y posición actuales. Habla mirando hacia ellas con B; algunas conversaciones inician escenas. La chica junto a la sala de Elman tiene un aviso específico: acercarte por el pasillo puede iniciar su escena. No se anticipan personajes ausentes de otra fase.

Los seis cofres del tesoro son seleccionables mientras permanezcan activos y sin abrir. Mira hacia el cofre y pulsa B. Su contenido se lee al abrirlo. Se retira el cofre abierto; los demás conservan sus claves y números. No se confunden estos cofres fijos con cofres de recompensa de enemigos.

Hay 15 referencias fijas de mobiliario: cuatro taburetes de la galería, cuatro camas de los soldados, horno, chimenea, dos mesas y barriles de la cocina, cama doble y mesa de la habitación del rey. Se justifican con el render de gráficos, paleta y metatiles nativos; se comprueba también la casilla viva de cada ancla. Son referencias de posición seleccionables, sin un sonido automático propio ni promesa de recogida o interacción.

Las escaleras identificadas usan `stairs.wav` de Chrono, ya presente en el runtime de Mana y verificado por hash. La señal de acceso reproduce esa muestra para una escalera, o la muestra de puerta para una puerta. Prioriza el acceso seleccionado y, en el castillo, el más cercano si no hay un acceso seleccionado. Radio de 64 píxeles, volumen creciente y paneo horizontal. Se cruzan caminando, sin B. La señal indica ubicación, no una ruta segura ni una garantía de acceso si una persona ocupa el paso. Control F9 con el menú abierto incluye la muestra en la guía.

Las paredes norte, sur, este y oeste conservan muestras, canales independientes, radio de 48 píxeles y ganancia existentes. El volumen mide proximidad al terreno bloqueante previsto en esa dirección; el sonido de choque procede del rechazo nativo del movimiento. No se deduce un choque de estar quieto. Menús, diálogo, escenas, ataques y transiciones suspenden la proximidad.

La evidencia y los límites de la entrega están en `tests/hormiga12-castle31-research/receipt.json` y al comienzo de `continuar.md`. Las poses y estados de historia preparados pertenecen solo a pruebas; no acreditan un recorrido completo por oído. La mezcla silenciada no sustituye la escucha del jugador.

Para revertir esta entrega, restaura del respaldo `backups/antes-castillo31.zip` únicamente `source/game.lua`, `source/terrain.lua`, `source/pandora.lua`, `source/reader.lua` y `source/sound-catalog.lua`, y aparta `source/castle.lua`. En `tests/test_reader01.py`, el total de muestras vuelve de 23 a 22. Conserva ROM, partidas, controles, runtime y todas las demás entregas.
