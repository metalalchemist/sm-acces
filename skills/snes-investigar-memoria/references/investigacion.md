# Investigar un adaptador de juego

## Recuperar el estado vigente

Consulta primero la continuación más reciente. Un índice histórico o una entrega antigua puede conservar pendientes ya resueltos y rutas anteriores. Para Chrono, el punto de entrada es [continuar chrono.md](../../../chrono-access/continuar%20chrono.md); el índice documental todavía menciona una entrega anterior como última.

Antes de elegir emulador, consulta preferencias y mediciones del proyecto. En este caso se eligió Snes9x con Lua porque BizHawk resultó lento para el usuario; esto no prohíbe otros emuladores para otros juegos. No des por disponibles `emu.frameadvance`, dominios de memoria o múltiples callbacks sin comprobar la API del fork concreto.

## Ficha mínima

Registra:

- Juego, región, revisión, traducción/parche, tamaño y SHA-256 de la ROM local.
- Mapper y cabecera de copiador; método comprobado para convertir offset de archivo a dirección del bus.
- Emulador, revisión, arquitectura y ABI de Lua y módulos nativos.
- Entrada principal, forma de observar un fotograma y estrategia para compartir hooks.
- Salida de voz, lector de pantalla, control habitual y asignaciones que deben conservarse.
- Separación de ROM, SRAM, savestates, configuración y evidencia de la copia de pruebas.

No confundas una dirección del bus SNES, un offset de ROM, una dirección WRAM y un puntero del proceso Windows. Prioriza las estructuras de la consola que expone el emulador. Conserva el archivo original; no apliques parches de ROM como consecuencia implícita de instrumentar un lector.

## Contrato de un dato

Para cada campo, anota dirección/dominio, ancho, endianidad, signo, escala, máscara, centinelas, validez contextual y rutina que lo produce. Añade qué captura y acción real lo validan y qué observación lo refutaría.

En Chrono, las coordenadas interiores del líder usan un índice de actor y punto fijo 12.4; el exterior tiene otro modelo y los vehículos otras coordenadas. Este ejemplo exige distinguir modelos; no proporciona offsets reutilizables en otro título.

Compara una sola acción reconocible cada vez: mover una fila, cancelar, cambiar de personaje, iniciar un diálogo, cerrar un menú. Captura también reposo y otro modo para detectar valores residuales. Los bytes de estado del planificador pueden ser reutilizados por otra tarea antes de terminar el fotograma: guarda el valor dentro de la rutina pertinente, después de su actualización.

Una firma valida que los bytes esperados están presentes en una ROM conocida; no demuestra por sí sola que el campo tenga el significado supuesto. Contrasta rutina, pantalla y transición de estado. Si falla la firma, informa de incompatibilidad y conserva el resto del lector.

## Fuentes locales contrastadas

- [Texto, posición y audio](../../../chrono-access/documentación/texto-y-audio-de-la-casa.md): hooks de glifos expandidos, callback central, escalas y concurrencia.
- [Configuración](../../../chrono-access/documentación/38-menu-de-configuracion.md): memoria temporal sobrescrita entre tareas.
- [Combate](../../../chrono-access/documentación/04-combate.md): cachés listas tras renderizar una fila; inventarios distintos de campo y combate.
- [Contexto y operación](../../../chrono-access/documentación/contexto-y-operacion.md): identidad exacta de ROM y preferencias históricas; contrasta sus ajustes con la continuación actual.
