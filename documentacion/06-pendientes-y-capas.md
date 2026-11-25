# Pendientes, rampas y capas

El aviso de proximidad ahora considera las mitades diagonales de una casilla y el cambio de capa bajo los pies. Mantiene las tres sondas por dirección, el alcance de tres casillas y los canales de sonido de la entrega 05. La cobertura continúa limitada a las cascadas de Potos, mapa 128.

## Reglas incorporadas

Los atributos `b2` 14–17 identifican las mitades inferior izquierda, superior derecha, superior izquierda e inferior derecha. Los códigos 1C–1F comparten esas orientaciones. Se comprueba la posición dentro de la casilla, en lugar de abandonar la sonda al encontrar una pendiente.

La altura, capa y marca de cambio se proyectan por separado en cada dirección. La altura se actualiza con la casilla bajo el centro, no con una casilla que solo alcanza una esquina del cuerpo. Las rampas tipo 0 conectan las alturas 1 y 2. Los tipos 4–7 mantienen la altura, lo que distingue circular sobre el puente de pasar bajo él.

Una casilla con `b0` bit 3 permite el paso del centro sin comprobar su borde. Al entrar, alterna la capa, activa la marca y deja altura 0. La marca impide alternancias repetidas mientras se sigue sobre casillas de cambio. Al salir se limpia y se adopta la altura de suelo cuando corresponde. El lector simula estos estados; no modifica el juego.

Fuentes locales: `references/som-decomp/maps.md`, secciones 14.1, 14.2 y 14.5; `hero-movement.md`, efectos de terreno y colisión. Se conserva su procedencia en `references/sources.json`. No se trasladaron direcciones de Chrono.

## Evidencia

38 pruebas del lector con Lua 5.1 real: PASS, registro `tests/pendientes06-model-tests.txt`. Incluyen formas diagonales y variantes, dimensiones, separación de capas, marca persistente, rampa, puente, silencio contextual y mezcla independiente del sonido de la espada.

La copia temporal `pendientes06-check` ejecutó `limits04.lua`: diez casos PASS. Hubo cuatro contactos de terreno con golpe, borde superior del puente bloqueado, paso inferior libre y cuatro caminatas libres sin golpe. Las posiciones iniciales se prepararon en esa copia y las flechas se procesaron por el motor; no es un recorrido natural desde el inicio.

La copia `terreno06c-check` ejecutó `pendientes06.lua`: siete casos PASS, terreno sintético y posiciones preparadas. Resultados nativos:

| Caso | Desplazamiento | Golpes | Estado final |
| --- | --- | --- | --- |
| Diagonal 14 | 0, 0 | 1 | Altura 2 |
| Diagonal 15 | 32, 12 | 0 | Deslizamiento, altura 2 |
| Diagonal 16 | 0, 0 | 1 | Altura 2 |
| Diagonal 17 | 32, −12 | 0 | Deslizamiento, altura 2 |
| Entrar en cambio de capa | 32, 0 | 1 | Capa 2, altura 2, marca limpia (82) |
| Salir con marca ya activa | 16, 0 | 1 | Capa 2, altura 2, marca limpia (82) |
| Rampa | 16, −4 | 0 | Altura 0 |

Las medidas internas de la tabla son píxeles; no se anuncian así al jugador. Antes de caminar, el modelo dio cercanía a la derecha de 2, 6, 2, 5, 34, 18 y 34 respectivamente. En los casos que detuvieron el avance, el motor quedó dos píxeles antes de esos contactos proyectados. Las pendientes 15/17 y la rampa desvían la trayectoria: proximidad a terreno no significa que sea imposible deslizar alrededor. El golpe puntual sigue dependiendo del rechazo nativo, y no se añadió un golpe por estos deslizamientos.

## Intentos conservados y límites

`terreno06-check` falló cinco casos: el arnés usaba IDs F0–F3, reservados para eventos nativos (los IDs a partir de la base C0 activan eventos sin depender del atributo de puerta). Se sustituyeron por B0–B3 exclusivamente en el ensayo. `terreno06b-check` obtuvo tres FAIL porque sus expectativas trataban todas las pendientes como bloqueos y la rampa como suelo a velocidad completa; el motor mostró el deslizamiento y la reducción descritos en la documentación. Se corrigieron esas expectativas y se repitió en `terreno06c-check`, exigiendo también el estado final de capa. Los fallos no se borraron ni cuentan como PASS.

Pendientes: escucha humana y ajuste de mezcla con NVDA, recorridos naturales y cobertura de otros mapas. La proyección recta no reproduce el deslizamiento lateral ni el tiempo que se tarda en cruzar una rampa. No se certifica jugabilidad completa por estas pruebas.

Respaldo anterior `backups/antes-pendientes-06.zip`. Para revertir solo esta entrega, restaurar `source/terrain.lua` de ese ZIP; conservar las otras funciones y todas las partidas. Las copias temporales se cerraron con el gestor propio de Mana. Sin sesión habitual abierta certificada para recarga: disponible al próximo arranque.
