# Qué se puede trasladar de las colisiones de Chrono

Se contrastaron el código actual de `chrono-access/rooms/reader.lua`, `rooms/model.lua` y la entrega 79 de Chrono con el módulo actual de Mana. Las direcciones y tablas de terreno no se trasladan entre juegos.

| Función | Chrono | Secret of Mana actual |
| --- | --- | --- |
| Proximidad antes de tocar una pared | Barridos sobre terreno real, muestras direccionales continuas, ganancia por distancia | No implementada; no confundir el sonido al chocar con este aviso continuo |
| Golpe al intentar un paso bloqueado | Interiores: intención, falta de desplazamiento y contacto fresco; exterior cubierto: rama nativa de rechazo | Rama nativa de terreno y rechazo temprano, con contexto del personaje en DP10 |
| Reposo y escenas | Se suspende o descarta el evento | Pruebas de modelo y prueba nativa de reposo; no se deduce colisión solo por quietud |
| Forma del terreno | Capas y pendientes propias de Chrono; su modelo usa límites de 1024 | Capas, alturas y semicasillas propias de Mana; mapa 128 tiene 896 por 1312 píxeles |

Por tanto, sí se aplica el principio de detectar un intento de movimiento rechazado y dar un aviso limitado, sin repetirlo cada frame. No sería válido copiar las direcciones de Chrono ni su límite fijo de 1024: produciría barreras falsas en parte de las cascadas de Mana y confundiría puentes con terreno infranqueable.

## Cobertura comprobada y pendiente

La entrega 03 comprobó una roca de las cascadas con movimiento nativo y señales del módulo real; hubo aviso al insistir, cero en reposo y cero en movimiento libre. También probó filtros de contexto, corriente, ataque y compañeros en Lua con capturas/variantes simuladas.

El mecanismo se observa en la rutina común de terreno, por lo que contempla rechazos que pasen por esa rama. No se certifican todavía todos los límites, semitriángulos, cambios de altura, orillas, mecanismos especiales o vehículos. Una salida que cambia de mapa y un borde por el que el motor permite pasar no son una pared por definición.

Se preparó `tests/limits04.lua` con diez casos: cuatro direcciones de sólido, borde superior de puente, paso por debajo y cuatro movimientos libres. La instancia adicional se cerró sin producir filas de resultados ni recibo final; no se admiten esos casos como PASS. Se conservaron el arnés, sus trazas y los metadatos de sesión. No hubo cambios de producción en esta comparación ni se operó una partida normal.

Próxima comprobación: resolver el arranque del arnés adicional, contrastar cada borde contra el desplazamiento nativo y solo entonces ampliar la declaración de cobertura. La proximidad continua requiere un modelo de terreno de Mana validado, separado del evento de choque ya existente.
