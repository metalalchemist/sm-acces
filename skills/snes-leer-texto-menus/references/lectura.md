# Lectura semántica y salida de voz

## Texto

Prefiere el punto del motor donde el texto ya está descomprimido y tiene nombres y variables resueltos. OCR puede servir como respaldo cuando no exista una extracción practicable; no lo conviertas en la primera opción si ya hay una rutina nativa verificable.

Reconstruye páginas a partir de glifos, saltos y controles de espera/cierre. Acota el búfer y registra códigos desconocidos en vez de inventar caracteres. Comprueba acentos, signos de apertura, nombres y números contra la traducción usada. Una tabla inglesa no valida un parche español.

En decisiones, conserva el texto de cada fila y lee el índice nativo seleccionado dentro de sus límites. Una página leída no implica que su cursor de respuesta también sea accesible.

## Estado y cadencia de voz

Usa una identidad semántica: contexto, personaje/actor, ventana, fila, valor y fase cuando corresponda. Una selección inmóvil debe permanecer silenciosa. Cambiar un valor sin cambiar de fila también debe anunciarse. Abandonar y volver a abrir el menú debe permitir la lectura inicial de nuevo.

Evita que un parpadeo de dibujo, una animación o una tarea ajena reinicien la identidad. Espera una fila renderizada completa cuando el cursor y sus cachés no se actualicen juntos. Declara cómo caduca la muestra al dejar de observar el contexto; no interpretes RAM antigua como un menú activo.

Las nuevas selecciones pueden interrumpir selecciones obsoletas; diálogos, recompensas y secuencias suelen requerir cola para no perder páginas. Comprueba los cruces entre lectores: el de campo no debe apropiarse del texto de combate, y un hook compartido debe repartir los eventos a los observadores pertinentes.

El callback CPU solo captura datos pequeños. El callback de fin de fotograma compone/anuncia mensajes. Un hilo de audio nativo recibe parámetros o muestras; no vuelve a llamar a Lua ni lee memoria del emulador. En Chrono se usa una única integración `emu.registerafter`; adapta esta regla a la API real de otro emulador.

## Combate

No anuncies «usado» al confirmar una orden que todavía está en cola. Lee costes actuales por participante, inventario del modo de combate, objetivos múltiples sin cortar listas en un centinela intermedio y resultado efectivo por cambios nativos. Respeta visibilidad de vida enemiga e información oculta. No describas como combate natural un encuentro preparado con RAM de prueba.

## Uso del asset

`assets/lector-observado.lua` es una factoría de solo lectura, no un lector de juego terminado. El adaptador aporta una rutina, sus bytes esperados y `read(memory)`, que devuelve `{context, key, text, interrupt}` como muestra nueva o `nil`. No registra otro callback de fotograma: el integrador llama al `tick` devuelto. Antes de usarlo, comprueba que ese hook no pertenezca ya a un distribuidor compartido. `missingFrames` controla la salida de contexto y debe medirse por juego.

## Fuentes locales

- [Texto y audio](../../../chrono-access/documentación/texto-y-audio-de-la-casa.md).
- [Combate](../../../chrono-access/documentación/04-combate.md).
- [Configuración](../../../chrono-access/documentación/38-menu-de-configuracion.md).
- [Grupo](../../../chrono-access/documentación/45-menu-de-grupo.md).
- [Selector del Epoch](../../../chrono-access/epoch-reader.lua): ejemplo de espera del fin de una animación.

## Acción en tiempo real

Distingue este modo del combate por menús. Usa los [contratos comunes de combate y audio](../../juegos-accesibles/references/contratos.md): señales de alcance y peligro según preferencia, objetivo estable y amenazas de todos los enemigos. Alcance previsto, barra recuperada y daño efectivo son estados distintos. Conserva consultas voluntarias por voz sin imponer coordenadas habladas continuamente.
