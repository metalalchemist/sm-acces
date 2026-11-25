# Recibo 02: selector de referencias y ventana accesible

Control F5 retrocede y Control F6 avanza entre referencias nativas compatibles. Control F7 consulta su dirección en casillas; por ejemplo «2 al sur, 4 al oeste». Se conservan medias casillas y décimas cuando hace falta. La distancia es por ejes en línea recta, no una ruta transitable. Arma pasa a Control F3 y ruta experimental a Control F4.

El primer mapa lista espada presente y salida conocida, avisando del requisito de cortar maleza. Los mapas compatibles con conejos listan los actores activos por slot estable. No se agregaron salidas ni objetos sin investigar. La selección sigue al actor y no salta silenciosamente al más cercano cuando se mueve. Al desaparecer, F7 informa que ya no está disponible. Durante escenas/rueda, selección y orientación quedan suspendidas.

La copia normal estaba configurada con WindowStyle Hidden. Ahora el lanzador usa Normal y un auxiliar propio restaura/muestra la ventana principal e intenta llevarla al frente. El auxiliar verifica ejecutable, PID y hora según `player/session.json`; no reinicia ni carga partidas. Los ensayos siguen usando ventanas ocultas y directorios propios.

Verificación: 23 pruebas reales de Lua 5.1, PASS (`tests/selector02-tests.txt`). Incluyen atajos integrados, referencia anterior/siguiente con vuelta circular, «2 al sur, 4 al oeste», media casilla, movimiento, desaparición y cambio de mapa. Son pruebas del módulo con RAM capturada y variantes simuladas, no una nueva valoración humana de navegación.

La primera copia oculta identificada ya se había cerrado cuando se intentó restaurar. No se operó un PID reutilizado. La comprobación final del nuevo arranque visible y de activación queda en `evidence/selector02-activation.txt`. No hubo cambios en la ROM ni en partidas. Inventario protegido en `evidence/integrity-after.json`.

Comprobación final real: copia normal PID 10964, ventana 1509334, visible, primer plano True y estilo Alt-Tab True, según `evidence/selector02-window.txt`. El auxiliar da el título «Secret of Mana - lector accesible», activa WS_EX_APPWINDOW y retira WS_EX_TOOLWINDOW de esa ventana verificada. No se reinició la sesión para mostrarla. El inicio nuevo del lector y los nuevos atajos están confirmados en `reader.log`; no se realizó una nueva prueba humana completa del recorrido.

Respaldo previo `backups/antes-selector-02.zip`; entrega `backups/selector-02.zip`, con SHA-256 en su inventario. Reversión: cerrar solo la copia propia si corresponde y restaurar fuente/entrada/lanzador de esta unidad desde el respaldo previo, conservando `partidas/`. No modificar Chrono.
