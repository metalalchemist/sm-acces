# Lectura de objetos, equipo y configuración

El lector anuncia nombres de la traducción, personaje seleccionado, cantidades y valores. Espera a que terminen las animaciones y permanece en silencio si la selección no cambia. No pulsa controles ni escribe memoria del juego.

## Controles para jugar

| Pantalla | Cómo usarla |
| --- | --- |
| Ruedas | Y abre; arriba/abajo cambia categoría; izquierda/derecha gira; X cambia al siguiente personaje disponible. El lector anuncia el nombre del personaje y de la entrada. |
| Objetos | B selecciona; escucha el objetivo y su vida. Otro B usa el objeto; Y cancela. Seleccionar todavía no consume una unidad. |
| Armas y armaduras | El primer B marca la pieza. Escucha «Pieza seleccionada». Otro B confirma el cambio para ese personaje; Y cancela. El aviso «Equipo actualizado» exige un cambio real en sus campos de equipo. |
| Armaduras | Las categorías distinguen cabeza, cuerpo y accesorios. Se lee la comparación de defensa cuando está disponible. «Tirar» se identifica como descarte y no se presenta como pieza de equipo. |
| Estado | Lee nombre, nivel, vida, magia de quienes tienen magia, experiencia, próximo nivel y diez atributos visibles. B cambia personaje; Y vuelve. |
| Niveles de armas | Lee las armas disponibles, nivel y progreso. B activa el selector; cruceta cambia la entrada; B muestra tipo y orbes; Y vuelve. |
| Niveles de magia | R cambia entre armas y magia para un personaje que tiene magia. Lee los elementos aprendidos y sus niveles. No equivale al menú para lanzar hechizos. |
| Comportamiento | Cruceta cambia la cuadrícula. B pasa a elegir carga máxima; arriba/abajo la cambia. B aplica; Y regresa. El lector distingue borrador de comportamiento aplicado. |
| Controles | Lee Y, X, B y A con sus funciones actuales para el mando seleccionado. Mantén el botón que quieres cambiar y pulsa izquierda/derecha; suelta para fijar esa asignación en el editor. L/R cambia mando. Start aplica; Select descarta los cambios; si sigue abierto, Select sale. |
| Ventana | Arriba/abajo cambia ventana; izquierda/derecha cambia estilo. Mantén A para rojo, Y para verde o X para azul y usa izquierda/derecha. B aplica; Select restaura los cambios pendientes; si sigue abierto, Select sale. |

**Control F1** repite la última lectura del submenú sin cambiar nada. **Control F2** consulta vida y magia del personaje seleccionado en ese menú u objetivo; en campo conserva la consulta habitual. Los demás atajos y las asignaciones del emulador se conservan.

Los nombres de botones anteriores corresponden a las pantallas y asignación inicial comprobadas. El editor de controles anuncia las funciones actuales: si cambias la asignación del juego, atiende también a esa lectura.

## Qué significan los números

«Cantidad» mide unidades del consumible que posees. «2 de 3» es la posición dentro de la rueda. La comparación de equipo indica valor actual y valor con esa pieza; no significa que se haya equipado. La lectura respeta nombres abreviados del juego y omite comparaciones que no puede identificar.

En Comportamiento, «Ataque a guardia» es la columna de la cuadrícula: 1 favorece ataque y 4 guardia. «Acercado a alejado» es la fila: 1 favorece acercarse y 4 alejarse. «Carga máxima» es el nivel de carga elegido, un indicador separado de esas dos coordenadas.

La lectura ahora nombra también el extremo o la zona central, contando columnas desde la izquierda y filas desde arriba:

| Posición | Horizontal | Vertical |
| --- | --- | --- |
| 1 de 4 | Extremo izquierdo: máximo ataque | Extremo superior: máximo acercamiento |
| 2 de 4 | Centro izquierdo: favorece ataque | Centro superior: favorece acercarse |
| 3 de 4 | Centro derecho: favorece guardia | Centro inferior: favorece alejarse |
| 4 de 4 | Extremo derecho: máxima guardia | Extremo inferior: máximo alejamiento |

No hay una casilla central única: las posiciones 2 y 3 son intermedias. La carga 0 significa que la IA usa ataques normales sin esperar una carga especial; no significa que deje de atacar. Si el arma de ese personaje solo permite el nivel 0, se anuncia expresamente. Cambiar la cuadrícula o el nivel modifica el borrador; B en el selector de carga lo aplica al personaje anunciado. Control F1 repite sin aplicar cambios.

Los valores de Comportamiento se anuncian tras dos fotogramas válidos, porque proceden de selectores nativos; así no se pierde un cambio rápido de carga 1 a 0. Las ruedas y los demás menús mantienen su espera para títulos renderizados. Los ensayos de esta ampliación están en `tests/hormiga12-behavior32-research` y la entrega 32 de `continuar.md`.

En Ventana se distinguen ocho ventanas y ocho estilos. Rojo, verde y azul son los componentes nativos de cinco bits, de 0 a 31; no son porcentajes. Cambiar de ventana consulta otra selección; cambiar estilo/color modifica el borrador del editor. Aplicar y descartar siguen las acciones nativas del juego.

## Evidencia y límites

La entrega usa `source/menu-data.lua`, `source/submenus.lua` y su integración en `source/reader.lua`. Se mantiene el lector de tiendas de la entrega 10. `menus.lua` conserva inicio y nombre; el nuevo módulo asume los contextos de juego identificados.

Las capturas de investigación están en `tests/submenus11b-research`. Allí se localizaron las páginas 4 (comportamiento), 5 (ventana), 6 (controles), 7 (estado), 8 (niveles de magia) y 9 (niveles de armas). El byte A201 cambia durante el dibujado y **no** identifica al personaje seleccionado. Se usa 19FE, y A22B en comportamiento, junto con observación vigente del renderizador.

La validación nativa final y su resultado están en `tests/submenus11d-check/result.txt`, `trace.tsv` y `receipt.json`. El código y el plan ejecutados están congelados en `frozen/`, con `frozen-inputs.json`. La prueba prepara inventario y compañeros en una copia privada: no acredita reclutarlos ni conseguir ese equipo jugando. Las entradas posteriores sí pasan por el motor real.

Resultado final: **83 pruebas Lua 5.1 y 43 comprobaciones nativas PASS**, sin fallos. Veinticinco entradas congeladas coinciden con los archivos ejecutados y la producción entregada; nueve archivos protegidos conservaron sus hashes. Registro de modelo: `tests/submenus11-final-model-tests.txt`.

Se ensayan consumo y cancelación de un objeto, cambio de arma, equipo de cabeza/cuerpo/accesorio, cambio de personaje, estado, selección y detalles de armas, niveles de magia aprendida, modificación y aplicación de comportamiento, modificación/aplicación/cancelación de controles y de ventana. El registro textual está silenciado; falta escucha humana con NVDA y valoración con el mando habitual.

No se certifican aquí lanzamiento de magia, todos los estados alterados, selección de enemigos desde Objetivos ni combinaciones de todos los objetos/equipos de la historia. «Objetivos» se anuncia en la rueda de opciones; la comprobación de destinatario realizada en esta unidad es para objetos sobre integrantes del grupo.

Se conservan los intentos previos: `submenus11-research` no había considerado la categoría Objetos al navegar; `submenus11-check` identificó que un B solo marca equipo; `submenus11b-check` mostró un inventario preparado con huecos; `submenus11c-check` tenía equivocada la navegación de categorías de armadura. No se presentan como ensayos completos aprobados. También se comprobó que el escritor nativo compartido de ajustes se ejecuta al salir tras cancelar: el anuncio de aplicación exige el callback nativo de confirmación correspondiente.

## Datos del adaptador y reproducción

| Dato | Fuente de esta ROM |
| --- | --- |
| Ruedas, personaje, cursor, cantidad, animación | 007D; 1808..180B; 1812 |
| Título renderizado y comparación | A1A4; D0 se interpreta como flecha solo en ese título de equipo |
| Marcado de equipo / destinatario | 1803 bits 40 / 20; selección de destinatario en la palabra apuntada por 1822 |
| Nombre de personaje | CC00 + 12 × personaje |
| Nombres de armas y elementos | Tabla CA0800; armas desde índice 32 hexadecimal, elementos desde 2A |
| Equipo confirmado | Campos E1E0..E1E3 por actor, observados entre fotogramas, con presencia válida y contexto de menú |
| Nivel y progreso de armas | Nibbles E1C0..E1C3 y bytes E1D8..E1DF por actor; contrastados con el dibujo nativo |
| Nivel de elementos | Nibbles E1C4..E1C7; presencia por máscaras E1C8..E1CF |
| Página y contexto modal | A202, observación de C020A7/C0281E, actor 19FE; se descartan reconstrucción y cierre |
| Cuadrícula, carga, actor de comportamiento | A136, A211, A22B; confirmación C76CA7 y campos persistentes A257/CC7D |
| Mando y asignaciones del editor | A220; permutación 9C00..9C03; Y/X/B/A corresponden a sus cuatro posiciones |
| Ventana, estilo y RGB | A24E; A24F..A256; palabras A23E..A24D |
| Aplicación de ajustes | C76FA7 y persistencia CC6D..CC6F; A209 distingue el callback aceptado de confirmación de la salida con Select |
| Detalles de niveles | Hook C76401; cursor A211, página y personaje; orbes CFB0/CFB8 |

Los hooks nuevos comprueban sus firmas antes de registrarse. Solo capturan eventos; la composición de voz ocurre en el tick central. Los lectores esperan 24 fotogramas estables, evitando el desfase medido entre cursor y título. El glifo C9 se confirmó como «ú» en la captura nativa de «Traje Kunfú»; su interpretación se limita al adaptador de menús.

Referencias de código identificadas por URL y hash en `references/menus11/sources.json`, procedentes del [checkpoint de som-decomp usado por el proyecto](https://github.com/cidwel/som-decomp/tree/715885595c6917220726d437211a57b58f615fc1). Se contrastaron con esta ROM Sayans; no se trasladan a otras ROM ni emuladores.

```powershell
python 'SM access/tests/receipt-submenus11.py'
```

El comando repite las pruebas de modelo y comprueba la identidad del código/evidencia e integridad. No vuelve a ejecutar por sí solo las acciones del motor. Para otro ensayo nativo, prepara un caso nuevo con el gestor propio de Mana y conserva el código congelado.

## Activación y reversión

Los cambios Lua requieren recarga verificada o el siguiente arranque del lector. No se carga ni reinicia una partida para activarlos. El recibo de continuidad indica cuál de esas situaciones se comprobó en esta entrega.

Al terminar se cerró la copia aislada identificada por el gestor. No había emulador habitual abierto: la entrega queda disponible al siguiente inicio con `iniciar-lector.cmd`; no se anuncia una recarga que no ocurrió.

Respaldo previo: `backups/antes-submenus-11.zip`. Para revertir solo esta entrega, recuperar únicamente `source/reader.lua` de ese ZIP y apartar `source/menu-data.lua` y `source/submenus.lua`. Conservar el lector de tiendas, las partidas, la ROM y los otros módulos. El cambio de prueba en `test_reader01.py` únicamente amplía la espera del caso de rueda para el nuevo tiempo de estabilización.
