# Contratos para accesibilizar juegos

## Controles y estados

Registra acción, entrada lógica, asignación física, contexto, efecto y confirmación. Comprueba conflictos con juego, plataforma y lector. Conserva preferencias existentes; no conviertas atajos de un proyecto en estándar universal.

Separa consultar, seleccionar, recalcular, descartar un tramo y ejecutar. Repetir una consulta estando quieto no modifica ruta ni objetivo. Si una orden descarta un paso, anuncia ese efecto y explica cómo reiniciar los descartes. Las unidades de distancia nunca equivalen automáticamente a pulsaciones.

Atajos de Chrono indicados por el usuario: Control F1 aprender sonidos; Control F5 orientar sobre la referencia; Control F6 seleccionar objetivos del mapa; Control F7 orientación/rutas del mapa exterior. Contrasta contexto y documentación vigente antes de cambiarlos. No trasladar los F5/F6/F7 de Mana a Chrono. En otros proyectos, descubrir y documentar su asignación propia.

Describe lo que realmente mide un indicador. En Mana «arma preparada» consulta recuperación de potencia; no demuestra alcance, impacto ni que haya terminado una animación. Distingue potencia, recarga, tiempo de lanzamiento y bloqueo de entrada según el juego.

## Lectura y combate

Obtén texto, selección y valores de una fuente válida para el contexto. Respeta información que el juego aún no revela. Gestiona prioridad, cola, repetición y caducidad para no anunciar estados obsoletos.

En combate por menús distingue orden seleccionada, confirmada, en espera, ejecutada y resultado. En acción en tiempo real acuerda voz o sonidos con el jugador; no impongas voz continua de coordenadas. Mantén un objetivo estable hasta selección explícita, desaparición o condición de cambio documentada. Revisa amenazas de todos los enemigos pertinentes, aunque no sean el objetivo seguido.

Separa distancia, orientación, alcance geométrico, recuperación y daño efectivo. Una previsión de alcance debe identificar arma, variantes, capas, obstáculos y estados cubiertos. Detectar cajas solapadas durante un golpe ya iniciado no es un aviso previo. Si una modalidad se desconoce, silencia su predicción o declara falta de cobertura. No prometas impactos frente a movimiento, evasión o azar.

## Interacciones y continuidad

Clasifica presencia, identidad, posición y condición de interacción: hablar, cruzar caminando, pulsar un botón, cortar con una herramienta, romper, recoger o abrir. Identifica herramienta, orientación y estado requeridos. Un cadáver, sprite o efecto no demuestra un recogible; no adivines el contenido de cofres. Revisa referencias al abrir, cortar, recoger, morir, reaparecer o cambiar la historia. No mantengas selecciones sobre actores reutilizados con otro significado.

Ofrece avance y regreso donde se hayan identificado accesos. Después de pelea o recompensa, comprueba que pueda localizarse el siguiente destino sin depender de enemigos derrotados. Distingue dirección directa de ruta transitable; termina rutas en el punto válido de interacción. Anuncia salida de cobertura en vez de dejar silencio inexplicable.

## Sonidos y aprendizaje

Mantén catálogo por proyecto: significado, muestra, condición, prioridad, canal, paneo, volumen, cadencia y finalización. Comprueba la muestra que llega realmente al mezclador. No confundas aproximación direccional, choque puntual, recogible, cortable, alcance, recuperación y peligro. Decide y comprueba escuchando cómo conviven proximidad y choque del mismo elemento.

Reserva canales/voces para evitar que actualizar una pared corte recompensas o alertas. Cesa señales sin contexto y limita repetición. Permite ajustar o silenciar familias, conservando preferencias. Usa un reloj apropiado; no presupongas frecuencia fija ni equivalencia entre tiempo emulado y real.

Ofrece guía accesible con las mismas muestras y nombres usados jugando. Si consultarla deja expuesto al personaje, requiere un estado seguro. Comprueba que el menú realmente pause ese juego; no asumas que todos pausan ni inicies ayuda automática para compensarlo.

## Pruebas y entrega

Identifica proceso/sesión o dispositivo; separa configuraciones, guardados y comandos de pruebas. Comprueba ventana visible, conmutación entre aplicaciones, foco recuperable y controles habituales en la plataforma real. Una copia oculta de pruebas no define cómo abre el juego habitual.

Congela al iniciar cada ensayo el código del arnés y los módulos usados, hashes, configuración y preparación. Ejecuta la copia congelada o verifica que coincide con lo ejecutado. Un hash de un archivo mutable no permite reproducirlo. Conserva intentos fallidos. Separa código de ROM, partidas y otros datos privados; no los incorpores indiscriminadamente a paquetes de código.

Separa modelo/simulación, motor, salida de audio/escucha y uso comprendido. Cruzar una salida desde una posición preparada no demuestra recorrer el sendero; una victoria del arnés no demuestra que el radar se entienda. Comprueba un ciclo de selección, aproximación, interacción, resultado y continuación/regreso, indicando partes pendientes. Registra comprensión, errores y preferencias del jugador, sin exigir reiniciar su progreso para evaluar mejoras.

## Un documento por entrega

Crea un archivo independiente para cada entrega, también para una corrección pequeña. Sigue la numeración y carpeta ya usadas por el juego, por ejemplo `documentación/NN-tema.md` o `documentacion/NN-tema.md`. Usa un nombre único; no sobrescribas el documento de otra entrega ni acumules entregas nuevas en un informe común.

El documento propio reúne uso y controles, cambios, cobertura y límites, pruebas y enlaces a evidencias/recibos, activación confirmada o pendiente, próximos pasos, respaldo y reversión de esa unidad. Los registros técnicos y recibos pueden seguir en sus carpetas de pruebas, enlazados desde el documento.

En el archivo de continuación deja una entrada breve para retomar: número y título, enlace «Lee…», resultado principal, controles o límites esenciales, validación resumida, activación y pendiente inmediato. Los detalles y el historial del ensayo van en el documento de la entrega, sin duplicar allí el informe completo. Actualiza el punto de entrada para que se encuentre primero la entrega vigente.

Modelo de organización: [continuar chrono.md](../../../chrono-access/continuar%20chrono.md) enlaza a [94. Epoch en todas las épocas](../../../chrono-access/documentación/94-epoch-en-todas-las-epocas.md). Toma su estructura documental; conserva los controles, rutas y datos técnicos propios de cada juego. Esta regla rige las entregas siguientes; no migres ni borres el historial existente salvo petición expresa.
