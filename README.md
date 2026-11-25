# Secret of Mana Access

Capa de accesibilidad para **Secret of Mana** que permite jugar a personas ciegas o con baja
visión mediante la narración de NVDA.

El lector se ejecuta como script Lua dentro de Snes9x-Lua. En cada fotograma inspecciona la RAM
del juego y traduce el estado del mundo a voz y a señales de audio espacial. No pulsa botones ni
escribe en la RAM del juego.

## Alcance: solo la versión en español de Sayans

Este proyecto se validó **únicamente** con la ROM *Secret of Mana (U)* con el parche de
traducción `[T+Spa102_Sayans]` (Sayans 102 %). No hay soporte para la versión en inglés ni para
otras traducciones, como la de Magno.

- `source/profile.lua` comprueba la identidad y la región de la ROM al cargar el lector.
- `source/reader.lua` usa esa comprobación y verifica las firmas de las rutinas antes de instalar
  cada hook de ejecución; si una firma no coincide, esa lectura se desactiva y se registra el
  problema en `reader.log`.
- Toda la narración, los perfiles de zona y la documentación están en español.

## Requisitos

- Windows.
- Snes9x-Lua 1.63, del fork <https://github.com/agehring80/snes9x-lua>, que incorpora la API
  Lua de gocha sobre `snes9xgit/snes9x`.
- NVDA.
- Una copia de la ROM *Secret of Mana (U)* con el parche Sayans 102 %, obtenida legalmente por
  la persona que la usa. **Ni la ROM ni el emulador se incluyen en este repositorio.**

Descargas compiladas de Snes9x-Lua 1.63:

| Versión | Enlace |
| --- | --- |
| Windows 64 bits (recomendada) | <https://github.com/agehring80/snes9x-lua/releases/download/1.63-lua/snes9x-lua-1.63-win32-x64.zip> |
| Windows 32 bits | <https://github.com/agehring80/snes9x-lua/releases/download/1.63-lua/snes9x-lua-1.63-win32.zip> |

Si se prefiere compilar el emulador, el repositorio del fork incluye las instrucciones para
Visual Studio.

## Instalación y configuración

1. Descomprimir Snes9x-Lua 1.63 en una carpeta local, por ejemplo
   `tools/snes9x-lua-1.63/snes9x-lua-1.63-win32-x64`. Debe contener `snes9x.exe` y la DLL de Lua.
2. Colocar la ROM con el parche Sayans 102 % en una carpeta local, por ejemplo
   `roms/Secret of Mana (U) [T+Spa102_Sayans].smc`. No se modifica ni se distribuye la ROM.
3. Editar `test/project.json` con las rutas locales. Las rutas relativas se resuelven desde la
   raíz del proyecto, así que se puede dejar la configuración portable:

   ```json
   {
     "schema": 1,
     "profile": "snes9x-lua-1.63-windows",
     "project_id": "sm-access",
     "rom_path": "roms/Secret of Mana (U) [T+Spa102_Sayans].smc",
     "emulator_dir": "tools/snes9x-lua-1.63/snes9x-lua-1.63-win32-x64",
     "config_template": "tools/snes9x-lua-1.63/snes9x-lua-1.63-win32-x64/snes9x.conf",
     "rom_sha256": "70F29FF2870171601333272F64A1B7F8040DE3C137F336B7AFCC97EC679951AD"
   }
   ```

   El valor de `rom_sha256` debe corresponder a la ROM con el parche indicado; el lanzador
   comprueba el hash antes de copiarla.
4. Ejecutar `iniciar-lector.cmd` desde la raíz del proyecto. El lanzador prepara una copia
   aislada del emulador en `player/`, copia la ROM a `player/Roms/game.sfc`, guarda las partidas
   en `partidas/` y genera `player/game.lua` con el lector cargado. Si el lector ya está activo,
   `recargar-lector.ps1` permite recargarlo desde la consola Lua sin reiniciar ni cargar una
   partida.

## Uso

| Script | Para qué sirve |
| --- | --- |
| `iniciar-lector.cmd` / `iniciar-lector.ps1` | Preparan la copia de juego y arrancan el emulador con el lector. |
| `recargar-lector.ps1` | Recarga el lector en la sesión abierta, sin tocar la partida. |
| `probar-hormiga.cmd` / `probar-hormiga.ps1` | Preparan una copia aislada para practicar el encuentro con la hormiga gigante. |

Teclas principales, con `Control` como modificador:

- `Control+F9`: abre la guía de sonidos; requiere tener abierto el menú del juego.
- `Control+F6`: selecciona la siguiente referencia.
- `Control+F7`: describe la referencia seleccionada y orienta hacia ella.
- `Control+F8`: calcula una ruta experimental evitando el paso bloqueado; solo está disponible
  en las cascadas de Potos, con el personaje libre.

## Qué narra

- Posición, orientación y ruta de caminata hacia el objetivo elegido.
- Personas, puertas, escaleras, cofres, tiendas y referencias del terreno.
- Menús: inventario, configuración, guardar y cargar, comercio, comportamiento, equipo y otros.
- Combate, alcance del arma, enemigos próximos, daño y alcance de los enemigos.
- Señales de audio espacial que apuntan a los elementos cercanos.

## Estructura

| Ruta | Contenido |
| --- | --- |
| `lector-snes9x.lua` | Punto de entrada: comprueba la ROM, inicializa la voz y conecta el lector. |
| `source/*.lua` | Módulos del lector: perfil de ROM, estado del juego, menús, mapas, combate y audio. |
| `runtime/` | Módulos nativos compilados, fuentes C/C++ y muestras de sonido. |
| `skills/` | Instrucciones reutilizables para asistir la investigación y las pruebas. |
| `documentacion/` | Documentación de cada entrega y de la investigación. |
| `continuar.md` | Registro de trabajo, avances y zonas pendientes. |
| `test/project.json` | Manifiesto local con ROM, emulador y configuración. |
| `partidas/` | Partidas aisladas de la copia de juego. |
| `player/` | Copia local del emulador, su configuración y el script generado. |

## Módulos nativos

- `runtime/chrono_prism.cpp`: puente de voz SAPI expuesto a Lua como `runtime/chrono_prism_v2.dll`,
  cargado por `source/reader.lua`.
- `runtime/chrono_audio.cpp`: fuente del mezclador anterior, conservada como
  `runtime/chrono_audio.dll`.
- `runtime/mana_audio_full.dll`: mezclador de señales espaciales que `source/reader.lua` carga
  efectivamente.
- `runtime/prism.dll`: [Prism](https://github.com/ethindp/prism), la capa de abstracción de voz y
  lector de pantalla sobre la que trabaja el puente. Se distribuye compilado en `runtime/` y su
  código fuente está disponible en el enlace anterior.

## Créditos y licencias

- **Código de este proyecto**: licencia MIT, texto completo en `LICENSE`.
  Copyright (c) 2026 metalalchemist.
- **Prism** (<https://github.com/ethindp/prism>): MPL-2.0, texto completo en
  `LICENSES/MPL-2.0.md`. `runtime/prism.dll` es una compilación de ese proyecto y se distribuye
  conservando su licencia.
- **Señales de alcance** (`runtime/sounds/range_in.wav` y `range_out.wav`): CC0 1.0, detalle en
  `runtime/sounds/range-license.txt`.
- **Resto de sonidos de `runtime/sounds/`**: muestras reutilizadas del proyecto
  *Chrono Access*; su procedencia y hashes se registran en `runtime/assets.json`. No son
  material extraído de *Secret of Mana*.
- **Snes9x-Lua**: se usa el fork indicado en la sección de requisitos, sin redistribuirlo aquí.

La MIT y la MPL-2.0 son compatibles: la MPL-2.0 solo impone obligaciones sobre sus propios
archivos (`prism.dll`), no sobre el código de este repositorio.

## Estado

Trabajo en curso, entregado por iteraciones. El avance, los límites comprobados y las zonas
pendientes están en `continuar.md`. La validez de la narración con NVDA depende todavía de la
escucha y la valoración de una persona jugando.
