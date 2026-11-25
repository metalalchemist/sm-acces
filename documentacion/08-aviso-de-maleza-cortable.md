# Saber cuándo cortar la maleza

Al acercarte y mirar hacia maleza que la espada normal puede alcanzar, se oye una señal breve. Si la escuchas, puedes pulsar B para intentar cortarla. La señal se repite con separación de 0,9 segundos y deja de sonar al cortar, alejarte o mirar a otro lado. No golpea automáticamente ni anuncia direcciones por voz.

La muestra es `furniture.wav`, reutilizada del runtime, distinta del golpe de pared y de los dos tonos de alcance contra enemigos. Para reconocerla, abre el menú del juego y pulsa Control F9: la guía incluye «Maleza u otro terreno cortable con la espada». No se añadió audio externo ni se sobrescribió una DLL.

## Cobertura

Se leen los atributos actuales del terreno en la capa del personaje. Solo C1 (espada) y C8 (espada/hacha) producen señal. C2, que requiere hacha, queda excluido. Las paredes y objetos sin atributo de corte identificado no se anuncian como cortables. Esto cubre maleza y terreno marcado por el juego; no todos los objetos golpeables o mecanismos de la aventura.

El modelo comprueba la orientación, capa y altura, una línea sin terreno bloqueante y la cobertura por las tres variantes normales de espada medidas en la entrega 07. Está habilitado en los mapas ya perfilados 128–131, comprobando dimensiones. No se proyectan ataques cargados ni otras armas. La señal se suspende en menús, escenas, ataques y movimientos forzados. Una casilla sustituida por suelo deja de cumplir el atributo de corte y deja de avisar.

`geometry.covered` contiene ahora la comprobación compartida de las cajas para el radar y para la maleza; se conserva el comportamiento conservador del radar. La señal nueva usa canal 15; no sustituye los canales del radar, la espada recogida, salidas o paredes.

## Pruebas

50 pruebas PASS con Lua 5.1 real; registro `tests/maleza08-model-tests.txt`. Los casos nuevos cubren orientación, desaparición tras sustituir la casilla, límite de repetición, exclusión del hacha y paredes, menús, ataques y arma incorrecta.

En `tests/cuttable08-check` se ejecutó una copia temporal con terreno sintético y personaje preparado desde la captura aislada `sword-free.ram`. No se cargó una partida del usuario. Se pulsó B a través de la entrada nativa del juego, sin forzar la rutina de corte:

| Terreno | Aviso antes de B | Resultado nativo |
| --- | --- | --- |
| C1 | Sí | Casilla B1 sustituida por suelo B0 |
| C8 | Sí | Casilla B1 sustituida por suelo B0 |
| C2, hacha | No | Casilla B1 conservada |
| Pared ordinaria | No | Casilla B1 conservada |

Resultado: PASS en los cuatro casos. Se usó el mezclador real con volumen cero; no equivale a escuchar la señal con NVDA. Pendiente valoración humana y recorridos con maleza real en Potos; no se certifican todos los objetos del pueblo.

## Activación y reversión

La copia temporal se cerró después de las pruebas. No había sesión habitual abierta para recargar, así que la función estará disponible al próximo inicio con `iniciar-lector.cmd`, sin reiniciar ni restaurar el progreso del jugador.

Respaldo anterior `backups/antes-maleza-08.zip`. Para revertir solo esta entrega: restaurar `source/reader.lua`, `source/geometry.lua`, `source/reach.lua` y `source/sound-catalog.lua` de ese respaldo y retirar `source/cuttable.lua`. No restaurar ROM, partidas ni configuración.
