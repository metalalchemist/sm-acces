# Práctica aislada de la hormiga y carga de espada

Abre `probar-hormiga.cmd` para practicar el primer jefe sin adelantar ni cargar tu partida habitual. La copia empieza con el menú abierto, espada inicial con habilidad 1 y cuatro dulces preparados solo para esta prueba. Tiene vida normal y no esquiva, ataca ni cura automáticamente.

1. Con el menú abierto, **Control F9** abre la guía de sonidos. Escucha sobre todo potencia recuperada, carga máxima, aviso preliminar, garras, proyectil y magia.
2. Cierra la guía y pulsa **Y** para cerrar el menú y empezar a jugar con tu mando.
3. **Control F3** consulta potencia y carga; **Control F2**, vida/magia. **Control F5/F6** selecciona la referencia de la hormiga y **Control F7** consulta su dirección en casillas. Esa dirección no es una ruta de esquiva.
4. **Control F10** reinicia exclusivamente esta práctica y vuelve al menú. **Alt F4** cierra la copia. Este atajo de reinicio solo existe en el lanzador de práctica.

El lanzador copia la configuración habitual de teclado/mando a la carpeta de prueba, cambia las rutas de guardado y usa velocidad normal. No modifica esa configuración original. La ventana se identifica como «Prueba aislada de la hormiga» y permanece separada de `player/` y `partidas/`.

## Potencia y golpe especial son distintos

El sonido habitual de arma recuperada indica **potencia al 100 %**. No significa que ya tengas cargado un golpe especial. Para cargar, mantén el botón de ataque —B con la asignación inicial— y suéltalo para ejecutar. El primer ataque y su recuperación pueden retrasar el comienzo de la carga.

La carga especial necesita habilidad de arma superior a cero. En tu partida normal, Control F3 explica si la habilidad actual es 0 y todavía no permite carga. La habilidad 1 de esta copia fue preparada para que puedas aprender su señal; no se trasladó a tu partida. Es la espada inicial, no un desbloqueo de la espada final de la historia.

Un tono ascendente señala un nivel intermedio; dos tonos ascendentes más agudos, la carga máxima disponible. El lector observa `E01B` y el límite nativo `E19C`, sin calcular la carga contando segundos o leyendo la tecla física. El contador parcial `E01A` no se presenta como nivel alcanzado. Al cargar se camina más despacio: primero conviene reconocer los avisos sin mantener el ataque y después probar la carga.

Los dos tonos fijos de alcance previsto conservan otra función: indican una posición/orientación de espada conservadoramente alcanzable. No son el sonido de carga máxima ni una garantía de impacto. Un tono grave indica fuera de esa previsión. Se suspenden durante carga, ataque o salto del jefe.

## Qué avisan los sonidos del jefe

| Aviso | Significado |
| --- | --- |
| Tono breve grave preliminar | Se acerca una decisión de ataque a corta distancia según su contador nativo. Todavía no identifica el ataque elegido. |
| Sonido corto descendente | Empieza una secuencia de garras. El margen es corto. |
| Sonido oscilante | Prepara garras con proyectil posterior o acaba de lanzar un proyectil que sigue al objetivo. |
| Tres pulsos | Magia o efecto dirigido. No se ha demostrado que caminar permita esquivarlo. |

El paneo sitúa al jefe a izquierda/derecha. Ningún aviso significa que una dirección esté libre de paredes o ataques. El prototipo no mueve al personaje ni promete esquivar todos los golpes. La prueba contigo sirve para valorar comprensión, margen de reacción y sobrecarga sonora.

## Evidencia

La arena se alcanzó mediante transiciones nativas 128→129→130→131, contacto con el Viejo y la escena real que lleva a mapa 260. Se partió de una captura privada del primer tramo y se prepararon posiciones para las transiciones; no se recorrió todo el camino por oído ni se cargó una partida del jugador. La hormiga fue creada por el motor y sus datos se contrastaron con las referencias de `references/hormiga12/`.

El estado de práctica se guardó con el diálogo nativo de Snes9x: `tests/hormiga12-research/Saves/arena-start.000.state`. Cada sesión copia ese archivo a su propio directorio y conserva su propio historial. La API Lua `savestate.create()` crea estados anónimos en memoria; pasarle un supuesto nombre o número no confirmó un archivo en disco. Se conservan los intentos y el fallo de identificación inicial del diálogo moderno.

La validación final está en `tests/hormiga12-check-f/`: `result.txt`, `measurements.txt`, `practice.tsv`, `receipt.json`, `model-tests.txt` y el código/sonidos/DLL/estado congelados enumerados en `practice-inputs.json`. El controlador automático se carga únicamente con `SNES_PRACTICE_VERIFY=true`; la práctica humana no llama a `joypad.set`.

En la muestra controlada, el preaviso apareció **55 fotogramas antes** de la primera caja de ataque y el aviso de garras **20 fotogramas antes**, aproximadamente 0,92 y 0,33 segundos a velocidad normal. El control quieto recibió el golpe. Son medidas de ese escenario, no tiempos mínimos garantizados de todos los ataques.

Se validó recuperación de potencia y llegada nativa a carga máxima de habilidad 1, avisos de proyectil y magia con ocho preparaciones de RNG, y un ataque de espada que redujo la vida del jefe desde una posición anunciada como alcanzable. Las pruebas de rango no certifican todos los movimientos, orientaciones o ataques cargados. Los ensayos usan posiciones, contadores, RNG y defensa preparados exclusivamente en la copia técnica.

La exploración `evasion-results.tsv` compara quedarse quieto con apartarse al inicio de las garras y tras retrasos de 12 o 20 fotogramas, con defensa/evasión cero para medir impactos. Apartarse inmediatamente evitó golpes en esas posiciones; con retraso de 12 fotogramas, retirarse hacia abajo funcionó y las retiradas laterales aún recibieron daño. Es exploración de posiciones concretas, no una regla universal de esquiva. Sus scripts se archivan como exploratorios; la aceptación final utiliza el controlador congelado.

Se detectó y corrigió un fallo de audio: los WAV iniciales eran de 48000 Hz, pero el mezclador exige mono PCM de 22050 Hz. Los ensayos anteriores podían registrar los avisos aun con el audio inactivo y **no acreditan sonido funcional**. Ahora la práctica exige `reader.audioActive`, los seis WAV tienen PCM no nulo y el mezclador real se carga y ejecuta silenciado durante la validación. Además, si una muestra falla al cargar, se cierra el mezclador ya inicializado para no dejar su hilo activo.

Las pruebas de modelo usan Lua 5.1 real y comprueban también firma incompatible, otro mapa/jefe, silencio en menú, separación de recuperación/carga, deduplicación y limpieza del audio fallido. La escucha humana sigue pendiente: cargar y mezclar en silencio no demuestra que los sonidos sean fáciles de distinguir.

## Alcance y reversión

`source/weapon-feedback.lua` añade recuperación y carga en el juego normal y amplía Control F3, conservando su función de consulta de arma. `source/mantis.lua` solo se activa mediante `bossPractice=true` en el lanzador aislado. El juego habitual todavía no recibe automáticamente esos avisos de jefe. No se anuncia accesibilidad completa del combate ni de otros jefes.

Se añaden seis sonidos propios; no se sustituyeron los sonidos anteriores ni DLL cargadas. La guía Control F9 incluye los nuevos ejemplos. Se mantienen los lectores de tiendas y submenús de las entregas 10 y 11.

Respaldo previo: `backups/antes-hormiga-12.zip`. Para revertir esta unidad en el lector habitual, recuperar solo `source/reader.lua`, `source/game.lua` y `source/sound-catalog.lua` de ese ZIP y apartar `source/weapon-feedback.lua` y `source/mantis.lua`. Después se pueden apartar el lanzador de práctica y los seis WAV nuevos (`charge_step`, `charge_max`, `boss_prepare`, `boss_claw`, `boss_projectile`, `boss_magic`). No restaurar ROM ni partidas. Conservar la evidencia de pruebas.
