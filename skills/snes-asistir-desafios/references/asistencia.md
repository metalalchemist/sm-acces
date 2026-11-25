# Ayuda opcional y control conservado

## No confundir tres clases de entrada

Separa botones SNES lógicos, asignación física del mando/teclado y atajos del emulador o lector. Un aviso «pulsa A» se refiere al botón lógico del juego; no impongas una tecla Windows como universal.

Audita atajos antes de añadirlos. En Chrono, F5/F6/F7 sin modificadores cargaban estados; las consultas requieren Control. Otro problema venía de flechas asignadas a cambiar periférico y permutar mandos: una aparente avería del lector era una configuración del emulador. Comprueba el estado real antes de explicar un síntoma por el código Lua.

No reescribas un archivo de configuración bloqueado por el emulador ni afirmes que una preferencia de sesión ya se guardó en disco. Para una reparación solicitada, conserva asignaciones del juego y modifica solo conflictos comprobados. Verifica persistencia tras un cierre normal, sin cerrar la partida por tu cuenta.

## Máquina de estados de asistencia

Describe activación, recorrido, interacción, espera, comprobación, recuperación y salida. Cada estado debe tener precondiciones y plazo. Define un límite finito de reintentos; las tres reentradas de la rata de Arris son un caso probado, no un valor obligatorio para todos los desafíos.

Permite escuchar instrucciones sin iniciar la ejecución. Inicia/cancela por flanco de pulsación para evitar alternancias al mantener el atajo. Al soltar control, cancelar, cerrar el lector o fallar, libera los botones inyectados. No dejes una dirección o A mantenidos después del retorno.

Comprueba mapa, modo, control, actores y flags nativos. Durante una transición válida puede faltar una posición de líder; espera solo dentro de los mapas y plazos previstos. Un desvío de recuperación necesita su propio límite de espacio y evidencia: no improvises un recorrido hacia un combate para desbloquear el guion.

Confirma el éxito con el estado del juego, no por haber terminado una secuencia de botones. Una ayuda puede reducir avisos repetitivos mientras trabaja, pero debe preservar instrucciones, cancelación y la salida de voz esencial.

## Verificación y alcance

Prueba inactividad fuera del contexto, instrucciones sin entradas, pulsación mantenida, cancelación a mitad, menú/combate, bloqueo, pérdida de actor y firma incompatible. Después valida el recorrido nativo y la liberación posterior de controles.

La preparación de RAM pertenece al arnés aislado; no debe filtrarse al módulo de asistencia de producción. Un ensayo que prepara una nota leída o una historia avanzada no demuestra haber obtenido esas condiciones jugando. Una recuperación probada sobre capturas tampoco demuestra que se ejecutó en todos los recorridos finales.

## Fuentes locales

- [Rata de Arris](../../../chrono-access/documentación/57-ayuda-opcional-para-la-rata.md): modelo de asistencia, cancelación y límites.
- [Conflictos del mando](../../../chrono-access/documentación/35-atajos-que-cambiaban-el-mando.md).
- [Aterrizaje del dáctil](../../../chrono-access/documentación/76-aterrizaje-dactil.md): ejemplo de informar sin pulsar A por el usuario.
