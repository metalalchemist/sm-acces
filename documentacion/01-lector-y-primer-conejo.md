# Lector inicial, espada y primer conejo

Ya hay un lector experimental para la ROM identificada en la investigación. Lee el inicio, la escritura del nombre y las páginas de texto; anuncia categorías y algunas selecciones de la rueda, vida a petición y señales para espada y conejo. No constituye accesibilidad completa de Secret of Mana.

## Para jugar

Pulsa **Start** en la pantalla de título para llegar al menú Empezar/Cargar.

Abre `SM access/iniciar-lector.cmd`. El lanzador verifica el SHA-256 y utiliza `SM access/player`, con partidas propias en `SM access/partidas`. Conserva el control configurado en la instalación fuente. No abre Chrono ni carga una partida de prueba. Exige una entrada nueva en `reader.log` antes de confirmar el lector.

En el inicio elige **Empezar** con B. Si no hay partidas guardadas, Cargar no se puede seleccionar: la rutina nativa lo impide. En el nombre, mueve la cruceta, añade letras con B y confirma con Start. En esta versión, **B también sirve para hablar, interactuar y atacar; Y abre y cierra la rueda**. La A ensayada no cerró la rueda; no presentar A como cancelación comprobada.

| Atajo | Función |
| --- | --- |
| Control F1 | Repetir la última página de texto |
| Control F2 | Vida y magia del personaje controlado |
| Control F3 | Consultar si el arma está preparada o recuperándose |
| Control F4 | Calcular una ruta experimental hasta la espada o salida del primer mapa |
| Control F5 | Referencia anterior: objetos, salidas o enemigos compatibles |
| Control F6 | Referencia siguiente |
| Control F7 | Dirección de la referencia seleccionada en casillas: «2 al sur, 4 al oeste» |
| Control F8 | Evitar el siguiente paso de esa ruta y recalcular, si el jugador comprueba que no puede cruzarlo |

Mantén Control sin Alt ni Shift. Las F solas siguen teniendo funciones propias del emulador, incluidos cargar estados; usa los atajos completos.

Después de la caída, la voz anuncia las cascadas. Selecciona la espada con Control F5/F6 y consulta su dirección con Control F7. La medida es de casillas de 16 píxeles internamente, pero la voz no habla en píxeles. Control F7 indica separación directa por ejes; no garantiza que puedas atravesar paredes. Control F4 ofrece la ruta experimental por terreno nativo; tú mueves al personaje. Todavía puede necesitar Control F8 en bordes, corrientes o rocas. Detente para escuchar una escena y continúa manualmente con B.

La aproximación a la espada usa sonido de objeto interactivo. Junto a ella, mira hacia la espada y pulsa B. Al extraerla, vuelve a sonar la señal y se anuncia la recogida por el cambio nativo de historia. Después, selecciona Salida al bosque con Control F5/F6 y consulta Control F7; Control F4 calcula la ruta experimental. Corta con B la maleza que bloquee el siguiente paso.

## Señales para reconocer

| Señal | Archivo existente | Significado y límite |
| --- | --- | --- |
| Choque con terreno | `wall_up/down/left/right.wav`, emisión limitada a 180 ms | El motor rechazó un movimiento intentado contra roca, pared o borde; separado de quedarse quieto, escenas y ataques |
| Objeto interactivo | `item.wav`, 330 ms | Espada próxima; también una emisión al extraerla |
| Enemigo | `enemy.wav`, 349 ms | Conejo compatible próximo, con paneo izquierda/derecha; selecciona con Control F5/F6 y consulta su dirección con Control F7 |
| Arma recuperada | `bell_timing.wav`, 60 ms | El contador nativo volvió a cero; no garantiza que el enemigo esté a alcance |
| Contacto geométrico de tu arma | `sign.wav`, 240 ms | La caja activa de la espada solapa el cuerpo del conejo; no garantiza daño |
| Amenaza en contacto | `wall_hit.wav`, 309 ms | Caja activa del conejo sobre cuerpo vulnerable del personaje, en el mismo plano observado |
| Daño recibido | `object_hit.wav`, 220 ms | Bajó la vida del personaje |
| Salida | `door.wav`, 310 ms | Cercanía de la salida al bosque, tras recoger la espada |

La amenaza de este prototipo representa geometría activa, no un aviso anticipado de todos los movimientos de IA. En el ensayo sonó tres fotogramas antes del daño; ese margen no se considera suficiente para esquivar por sí solo. El radar de proximidad ayuda a conocer dónde está el enemigo antes del ataque. La predicción del golpe aún no está implementada.

Si el sonido de la espada te llega desde lejos, todavía no estás al alcance de B. La referencia da distancia directa, que puede cruzar una orilla rocosa. La recogida comprobada fue desde el norte de la espada, mirando al sur. Si la guía agotó los pasos descartados con Control F8, Control F4 reinicia ahora la búsqueda sin esas exclusiones.

Se reutilizan sonidos autorizados por el usuario y ya cortos del runtime. No se descargaron sonidos externos ni se afirmó dominio público. Se evitó `connection.wav` para el contacto de arma porque dura 2,28 segundos y taparía la acción. No fue necesario FFmpeg.

## Qué se comprobó

Se extrajo la espada mediante B frente a su actor real: en `sword-before.ram`, historia `CF10=0` y actor D8 activo; en `sword-collected.ram`, `CF10=1` y actor desactivado. El arma ya figuraba equipada antes de esa escena, por lo que el inventario no era una prueba de recogida.

El recorrido de pruebas usó botones nativos, incluyendo cortar vegetación y cruzar **128 → 129**. El primer conejo pasó de 20 HP a cero y el personaje conservó 50 HP. Otro ensayo, sin atacar, registró **50 → 46 HP**. El lector anunció el daño. La versión con geometría registró amenaza en el fotograma local 299 y daño en el 302. La práctica fue automatizada únicamente en el arnés aislado: no demuestra todavía que una persona complete ese trayecto por oído.

Las cajas se contrastaron con capturas: cuatro bytes `offset X con signo, offset Y con signo, ancho, alto`. Ejemplo observado de espada: `(16,-26,32,32)`. Se omiten cajas vacías y planos distintos. Precisión de impactos, invulnerabilidad, orden de actualización y ataques ya consumidos pueden impedir daño aunque haya solapamiento. No se publica un radio fijo como alcance garantizado.

El inicio limpio validó nombre A → B → C, escritura de C y después CB, confirmación y prólogo con el módulo real. Los cambios de selección se observan en el manejador nativo del menú por fotograma; el hook de apertura solo no bastaba. Se conservan los primeros intentos fallidos. Cargar quedó deshabilitado por ausencia de partidas, según `A215=FF`; no se inventó una selección disponible.

## Límites de esta entrega

La orientación inicial y las rutas se limitan a las cascadas; el radar de conejos contempla los mapas 129 y 130, pero el combate nativo solo se ensayó en 129. Las rutas pasivas de producción tienen comprobaciones con RAM capturada; no se ha recorrido cada instrucción de esa guía con un jugador. Los controladores de investigación que reparan rutas y pelean están únicamente en `tests/` y nunca se cargan en juego normal.

La rueda ensayada cubre armas y opciones iniciales. No están certificados los submenús de armadura, tiendas, magia, objetivos múltiples, guardado ni cambio de compañeros. La lectura genérica de texto de la rueda se suprime para no leer números de dibujo como frases. No se anuncian nombres inventados para selecciones aún desconocidas.

Charset confirmado en texto observado: á, é, í, ó, ¡ y ¿. El menú de nombre usa su conversión de glifos de la ROM y conserva W. Aún faltan caracteres no vistos, incluida ñ. Los códigos desconocidos se conservan en el registro.

La inicialización de Prism encontró **NVDA** y el mezclador cargó PCM y aceptó reproducción con ganancia cero en la copia. Falta valoración humana de la voz, identificación de timbres, sobrecarga sonora y utilidad de las amenazas con el control.

## Continuar y revertir

Siguiente unidad: escuchar esta versión con NVDA y control, afinar el radar y la ruta real a la espada, y ampliar la rueda a equipo y objetivos. No anunciar accesibilidad del juego entero por superar el primer encuentro.

Para volver al estado previo, cierra únicamente la copia `SM access/player/snes9x.exe` y deja de utilizar su lanzador. Conserva `partidas/`. El respaldo `backups/antes-lector-01.zip` conserva la documentación previa; el de entrega conserva código y evidencia. No restaures partidas ni archivos de Chrono.
