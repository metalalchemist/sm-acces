# Recibo de investigación inicial

Fecha: 18 de noviembre de 2026. Entrega: identidad de ROM, investigación técnica, capturas nativas de texto y entorno aislado de Secret of Mana. No se entregó lectura por voz ni un detector de alcance.

## Comprobaciones realizadas

| Capa | Comando o escenario | Resultado | Evidencia |
| --- | --- | --- | --- |
| Identidad | `venv/Scripts/python.exe "SM access/investigar.py"` desde tools con ruta al venv del proyecto padre | HiROM de 2 MiB; hash registrado | `evidence/rom-identity.json` |
| Gestor | `python -m unittest discover -s "SM access/tests" -p test_emulator_manager.py -v` | 6 pruebas, 16,898 s, OK; sin iniciar emuladores en esta suite | Resultado observado en la consola; nombres de escenarios en `tests/test_emulator_manager.py` |
| Preparación | Gestor `Prepare`, después `Start -Case smoke-check -Script smoke.lua -PrepareOnly` | Copia y configuración propias, sin ejecutar en PrepareOnly | Sesión `20261118-132429-682-shared` |
| API real | Gestor `Start -Case smoke-check -Script smoke.lua` | `PASS project=sm-access frames=120`, WRAM de 131072 bytes y captura GD | `tests/smoke-check/smoke.txt`, `smoke-ram.bin`, `smoke.gd` |
| Texto, intento 1 | Gestor `Start -Case research-check -Script research.lua` | 1800 frames, 407 llamadas al hook; bienvenida y nombre. Start con nombre vacío no continúa | `tests/research-check/research.txt`, `glyphs.tsv`, `observations.tsv`, capturas |
| Motor, inicio nuevo | Gestor `Start -Case native-start-check -Script research-start.lua` | 3600 frames, 751 llamadas al hook; nombre A y entrada al prólogo mediante botones; sin escrituras de RAM | `tests/native-start-check/research.txt`, `glyphs.tsv`, `observations.tsv`, capturas |
| Texto y pantalla | `analizar.py` para ambos casos; inspección visual de PNG 1500 y 3600 | Alfabeto base coherente en texto observado; C3 á, C4 é, C7 ó corregidos en contrato parcial | `source/charset-observed.json`, imágenes y `text-hypothesis.json` |
| Activos locales | `preparar-runtime.py` | 24 archivos: 19 WAV, 3 DLL y 2 fuentes C++; sin reproducción. DLL PE 8664 | `runtime/assets.json` |
| Integridad | Repetición de `investigar.py` tras cerrar la copia | 14 archivos comprobados, 0 cambiados, 0 añadidos en el inventario protegido | `evidence/protected-before.json`, `integrity-after.json` |
| Audio/Prism/NVDA | No ejecutado | No se cargaron DLL, reprodujeron WAV ni emitió voz; sin valoración humana | Pendiente |
| Menú circular, rutas y combate | No ejecutado | Datos de fuentes conservados como candidatos; no hay prueba local de alcance ni de navegación | Informe de investigación |

`PASS` en los guiones de observación significa que terminó el presupuesto de frames y se guardaron archivos, no que un lector accesible haya superado pruebas semánticas. El inicio nativo se corroboró con texto y pantalla; no se afirmó juego completo.

## Identidad de las copias y cierre

Las instancias compartidas usaron exclusivamente `SM access/tests/emulator/snes9x.exe`. Sus sesiones reales quedaron archivadas bajo cada caso:

- Smoke: PID 9292, inicio `639306338876145103`, sesión `20261118-132446-870-shared`.
- Texto/nombre: PID 4576, inicio `639306345189558758`, sesión `20261118-133518-596-shared`.
- Inicio/prólogo: PID 9268, inicio `639306378038996819`, sesión `20261118-143003-512-shared`.

Son identidades históricas de esta entrega, nunca autorización para operar futuros PID iguales. El gestor verificó propietario, ruta y hora antes de cerrar cada copia. Tras el último Stop no apareció ningún proceso `snes9x` en la comprobación realizada. SRAM, estados, capturas y configuración de cada ensayo están redirigidos a su caso; no se usó el gestor de Chrono ni se recargó una sesión habitual.

Los botones se neutralizan en cada frame de prueba; los scripts no tienen un canal de órdenes históricas. Los experimentos solo se ejecutaron en copias silenciadas. No hubo inyección de RAM, carga de una partida del jugador ni modificaciones a la ROM.

El inventario protegido cubre la ROM de Mana, SRAM de la raíz y los archivos seleccionados de la instalación fuente (guardados, configuración, Lua y binarios). No es un inventario de todo el repositorio. No se restauró ningún archivo protegido.

## Respaldo y reversión

Unidad sin commit: carpeta nueva `SM access`, con infraestructura, código de investigación, datos parciales, documentación, fuentes de consulta y soporte copiado. `tools/` está ignorado por Git; no se usó Git como respaldo.

El archivo `backups/investigacion-inicial.zip` conserva documentación, guiones, manifiesto, inventarios, soporte y evidencia seleccionada. Excluye ROM, SRAM y binarios del emulador. Su inventario y hash están en `evidence/backup.json`. Es un respaldo local dentro del proyecto; copiarlo a otro medio si se necesita protección frente a pérdida de la unidad.

Para revertir esta entrega, dejar de ejecutar sus pruebas y apartar únicamente `SM access` una vez comprobado que no tenga procesos activos. No restaurar ROM, SRAM, configuración ni archivos de Chrono. Ningún lector quedó activado para uso habitual.
