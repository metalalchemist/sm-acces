# Camino oeste de Pandora, Gaia, Kippo y Neko

La salida oeste de Pandora lleva al camino con desvíos hacia Kippo y el Ombligo Gaia. Se añadieron sus accesos, letreros y personas presentes, las casas y comercios de Kippo, la cueva de Neko y los primeros tramos de las cavernas de Gaia.

## Controles

Control F5 y Control F6 seleccionan la referencia anterior o siguiente. Control F7 consulta su dirección, distancia en casillas de 16 píxeles e instrucciones. Consultar conserva la selección: no mueve al personaje, calcula rutas ni descarta pasos. La distancia directa no garantiza un paso entre paredes, desniveles o muebles.

Los accesos señalados se cruzan caminando. Para hablar con una persona o leer un letrero, acércate, mira hacia ella o él y pulsa B. Las personas se siguen por posición y presencia nativas. Una referencia desaparecida deja de estar disponible; elige otra con F5/F6.

## Cobertura

| Zona | Referencias |
| --- | --- |
| Camino oeste de Pandora | Regreso a Pandora, desvío a Kippo, camino a Gaia y letrero del cruce |
| Exterior del Ombligo Gaia | Regreso, letrero, entrada a la cueva de Neko, entrada a las cavernas y salida hacia el Bosque Encantado |
| Pueblo de Kippo | Tres habitantes presentes, salida al camino, dos casas, tienda y posada |
| Interiores de Kippo | Personas de cada casa, comerciantes, regresos, ambas plantas de la casa con escaleras y once muebles fijos |
| Cueva de Neko | Neko presente y salida al exterior de Gaia |
| Primeras cavernas de Gaia | Primera caverna en dos tramos, segunda en tres tramos, escaleras, accesos y sala lateral con un cofre |

La continuación profunda desde la segunda caverna y el siguiente tramo del Bosque Encantado todavía no están catalogados; sus referencias lo indican. No se presenta todo el subterráneo como cubierto. Las salas compartidas se separan por mapa, dimensiones, entrada, procedencia y sector. En Neko se excluyen marcas de la tabla compartida que no son accesos desde su sala.

Los guardias de Pandora conservan sus referencias anteriores. Los nuevos registros del camino contienen monstruos; Kippo tiene habitantes y comerciantes, y la cueva tiene a Neko. No se convierten esos actores en guardias por su aspecto. Los enemigos ordinarios identificados usan sus nombres de esta ROM y el radar existente; las previsiones de alcance conservan los perfiles de espada, lanza y nudillo.

Los muebles son referencias de posición, sin sonido automático propio ni promesa de recogida. El cofre lateral se anuncia mientras está presente, su contenido se lee al abrirlo con B y su referencia se retira después. No se anticipa el contenido.

## Sonidos y límites

Las paredes norte, sur, este y oeste mantienen las muestras, canales, paneo y volumen anteriores. La proximidad mide un rayo de terreno de hasta 48 píxeles; el choque se anuncia por el rechazo nativo del movimiento. En esquinas, pendientes y cambios de altura el motor puede deslizar al personaje: esa distancia recta no es una ruta ni predice toda su trayectoria.

Las escaleras señaladas usan `stairs.wav` de Chrono, ya presente en Mana. Se mantiene el canal de acceso: reproduce escalera o puerta, priorizando el acceso seleccionado y después el más cercano en estas zonas. Control F9, con el menú abierto, permite reconocer la muestra. Menú, diálogo, escena, ataque y transición suspenden la proximidad.

La investigación distingue RAM capturada, render de gráficos/metatiles nativos, simulación del lector y acciones del motor. Las pruebas usan poses y salud preparadas; para aislar paredes y accesos se apartaron actores solo en la copia. La prueba de cofre tampoco acredita vencer a sus enemigos. El mezclador real estuvo silenciado; queda pendiente la escucha del jugador y un recorrido completo por oído.

El recibo está en `tests/hormiga12-gaia33-research/receipt.json`; la activación se registra al comienzo de `continuar.md`.

## Reversión

Restaura del respaldo `backups/antes-gaia-kipo33.zip` únicamente `source/game.lua`, `terrain.lua`, `reader.lua`, `pandora.lua` y `sound-catalog.lua`. Aparta `source/gaia.lua` y `source/gaia-furniture.lua`. Conserva ROM, partidas, configuración, charset C9, comportamiento, nudillo y referencias anteriores.
