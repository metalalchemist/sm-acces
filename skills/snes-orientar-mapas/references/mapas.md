# Referencias, rutas y señales

## Identidad y presencia

Separa modelo de memoria/terreno, perfiles de zona y presentación sonora. Conserva el orden explícito cuando varios perfiles compartan mapa y límites. Si un generador crea el perfil, actualízalo o establece una delegación mantenida; no dejes una corrección que desaparezca al reconstruir.

Usa identidad estable de actores para numerar personas y cofres durante movimiento y desaparición. Identifica controladores, puertas, efectos y tesoros antes de anunciarlos como personas. Un sprite catalogado como enemigo puede ser una criatura conversable; el Nu del hangar de Chrono lo demuestra. No generalices una excepción de actor a todo el juego.

El dibujo puede alternarse por parpadeo sin que desaparezca un objeto. En la catedral de Chrono hubo que observar procesamiento y tipo del actor; un temporizador que ocultara la repetición habría encubierto la causa. Comprueba recogida, procesamiento desactivado y dibujo residual como casos distintos.

Los vehículos siguen mapa de estacionamiento, presencia, coordenadas y modo nativos. No crees una copia fija en cada época. Un muelle interior puede tener un evento de contacto y una decisión, mientras un exterior exige A y solapamiento. Usa el mecanismo real de cada acceso.

## Geometría y rutas

Documenta origen, unidad, punto fijo, dimensiones del cuerpo, capas, pendientes, envoltura del mapa y sectores desconectados. Diferencias de coordenadas solo orientan; no prometen atravesar paredes, barandillas o huecos.

Extrae salidas y condiciones de activación. Agrupa entradas únicamente cuando representen el mismo acceso; dos bocas que llevan al mismo interior pueden pertenecer a sectores distintos. Resuelve redirecciones de tablas antes de interpretar registros: coordenadas cero pueden ser un enlace, no un tesoro en (0,0).

Termina la ruta en el punto que permite la interacción: zona activa de puerta, pie de escalera, contacto o alcance del vehículo. No uses una marca de puerta para abordar transportes. Avisa cuando no hay ruta; no uses distancia directa como sustituto silencioso.

## Audio

Usa familias de señales distinguibles, ganancia por proximidad y paneo. Mide una cadencia ligera con reloj monótono; los dos barridos por segundo y cuatro casillas de Chrono son un ajuste de ese proyecto, no valores universales. Separa la mezcla continua del evento puntual de choque y consume este una sola vez. Un paso bloqueado debe venir de la rama nativa o de una comprobación fresca de intención y contacto, no de estar quieto.

Silencia proximidad durante menú, diálogo, combate, pérdida de control y salida de cobertura. Conserva avisos de entrada/salida sin repetir toda la sala al cerrar una conversación. Ofrece una guía para reconocer las señales antes de usarlas como instrucciones.

## Ejemplos locales

- [Mapa exterior y meta de entrada](../../../chrono-access/documentación/06-mapa-exterior.md).
- [Perfiles modulares](../../../chrono-access/documentación/69-rooms-modulares.md).
- [Parpadeo y presencia](../../../chrono-access/documentación/44-parpadeo-del-objeto-sin-repetir-la-nave.md).
- [Cofres redirigidos y mecanismos](../../../chrono-access/documentación/77-interruptores-y-cofres-del-tirano.md).
- [Choques nativos](../../../chrono-access/documentación/79-colisiones-12000.md).
- [Epoch y plataformas](../../../chrono-access/documentación/94-epoch-en-todas-las-epocas.md).

## Interacciones y uso general

Aplica los [contratos comunes](../../juegos-accesibles/references/contratos.md) al clasificar cortables, rompibles y recogibles; comprobar continuidad tras combate/recompensa; mantener objetivos estables y revisar amenazas; y asignar muestras/canales inequívocos. Conserva los controles de cada proyecto: consultar no descarta pasos. Prueba la guía sin dejar expuesto al personaje y comprueba si el menú realmente pausa.
