# Proximidad de paredes: adaptación inicial de Chrono

Esta es la entrega inicial. La [entrega 06](06-pendientes-y-capas.md) incorpora pendientes y cambios de capa y añade pruebas de movimiento nativo; sustituye los límites indicados aquí para esas geometrías.

Al acercarse a terreno bloqueado en las cascadas de Potos, el lector reproduce el sonido de su dirección y aumenta su volumen. Izquierda y derecha llevan paneo. El alcance inicial es de tres casillas; no expresa distancias en píxeles al jugador. El sonido de colisión sigue siendo un evento independiente al intentar un movimiento que el motor rechaza. La espada conserva su aviso interactivo y el de recogida.

## Implementación y cobertura

Se reutiliza el método de Chrono, con datos propios de Mana: dimensiones nativas en píxeles, capas `7F0000/7F4000`, atributos `7FB800/7FBC00`, casillas de 16 y altura/capa de `E00B`. Solo se habilita en mapa 128 y con sus dimensiones comprobadas. Son tres sondas por dirección, con semiancho 6 y semialto 4, hasta 48 píxeles; volumen máximo 0,24 por canal. Actualización cada 200 ms. Los canales 8–11 repiten las muestras existentes, sin limpiar los canales de objetos, enemigos o choque.

Los tipos sólidos y las diferencias incompatibles de altura avisan. Los tipos transitables actualizan la altura simulada de la sonda. Las pendientes diagonales y los cambios de capa son desconocidos para este primer perfil: se detiene esa sonda sin anunciar pared. Los límites usan 896 × 1312, sin copiar el límite de 1024 de Chrono. No cubre obstáculos móviles ni garantiza aviso en todo el juego.

## Comprobación

`tests/test_reader01.py` usa Lua 5.1 real del emulador, ROM local y capturas de RAM. Comprueba roca, puente superior frente al paso inferior, dimensiones, bordes, terreno desconocido, aumento de volumen, silencio en escena y separación de canales frente a recogida/choque. Las variantes de posición y altura son simuladas. Resultado actual en `tests/proximity05-model-tests.txt`.

El intento de movimiento nativo `proximity05-check`, basado en `walls03.lua`, se cerró antes de generar muestras; el TSV vacío y el archivo de sesión conservan el intento. No acredita acercamiento nativo ni audio escuchado. La entrega 03 sí comprobó el rechazo nativo contra la roca; no extender esa evidencia a esta función nueva. Pendientes: recorrer el puente y acercarse a obstáculos con el perfil nuevo; valorar con NVDA volumen y distinción de las señales.

El lector de juego carga los módulos desde `source/` al arrancar. Si no existe una sesión normal identificada, queda disponible al próximo inicio sin abrir ni cargar partidas por cuenta propia. No se cambian las DLL, ROM o guardados del jugador.

Respaldo: `backups/antes-proximidad-05.zip`. Reversión: restaurar únicamente `source/reader.lua` anterior y retirar `source/terrain.lua`; conservar las demás funciones y todos los guardados.
