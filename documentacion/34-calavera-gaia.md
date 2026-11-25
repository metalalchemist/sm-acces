# Calavera interruptor de la segunda caverna de Gaia

En el tramo superior de la segunda caverna de Gaia, junto a los Niños Goblin y la escalera, se añadió la referencia **Calavera interruptor de la segunda caverna**. Es un mecanismo fijo de pared, no un enemigo ni un objeto recogible.

Control F5/F6 la selecciona y Control F7 informa su dirección en casillas. La instrucción es concreta: golpearla una vez con el arma. El juego deja caer agua sobre la lava y la enfría; luego hay que bajar por la escalera y cruzar el paso enfriado. No se pulsa B ni se activa caminando. Consultar o seleccionar no golpea la calavera ni cambia el paso.

La referencia está limitada al contexto nativo del tramo superior del mapa 285 y a su metatile inferior observado en la captura `zone285-upper.ram`. Se retira si ese metatile ya no está presente. La posición observada es (248, 152); no se anuncian otros adornos de calavera como interruptores.

El lector se validó con la captura aislada: la referencia aparece con tipo `switch`, conserva la instrucción de enfriar la lava y se retira al invalidar la casilla ancla. La acción de golpear y el enfriamiento se documentan como comportamiento del juego confirmado por el jugador y contrastado con guías; la reproducción nativa aislada queda pendiente porque la instancia temporal no llegó a iniciar su script. No se abrió, cargó ni modificó la partida habitual.

La activación se mantiene disponible al siguiente inicio; editar archivos no recarga una instancia que ya esté abierta. Para revertir esta corrección, retira únicamente el bloque `gaia33:skull-switch` de `source/gaia.lua`, restituye la entrada 22 de `source/sound-catalog.lua` y elimina esta documentación; no restaures ROM ni partidas.
