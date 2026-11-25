# Un gestor y sus pruebas dentro de cada juego

## Qué se reutiliza y qué queda separado

La skill incluye el código fuente del gestor bajo `assets/runtime/`.
El creador `scripts/nuevo-proyecto.py` lo copia a cada proyecto nuevo.
No depende del directorio ni de las direcciones de Chrono y no descarga ROMs.
El perfil implementado es **Snes9x Lua 1.63 para Windows**; otro fork/emulador
requiere adaptar y comprobar su API, configuración y arranque Lua.

Cada proyecto tiene esta estructura:

```text
earthbound-access/
  continuar.md
  source/                         # Adaptador y lectores de ese juego
  tests/
    project.json                  # ROM, hash, emulador y configuración propios
    emulador-pruebas.ps1           # Copia independiente del gestor
    enable-background.ps1
    smoke.lua
    test_emulator_manager.py
    emulator/                     # Binarios copiados; no es el emulador habitual
    emulator-temp/                # Instancias temporales de este proyecto
    smoke-check/
      Saves/                      # SRAM y estados exclusivos del caso
      Roms/ Screenshots/ Movies/   # Directorios exclusivos del caso
      sessions/                   # Configuración, identidad y evidencia archivadas
```

`illusion-access` tendrá el mismo esquema bajo su propia raíz. Se pueden
ejecutar ambos juegos simultáneamente: el bloqueo, propietario, PID, ejecutable
y datos de uno no pertenecen al otro. Dentro de un proyecto, la instancia
compartida solo permite un caso activo; `-Temporary` crea otra instancia y
prohíbe usar simultáneamente el mismo caso.

## Crear los proyectos

Desde VeMovie, sin abrir juegos ni modificar ROMs:

```powershell
python skills/snes-probar-lector/scripts/nuevo-proyecto.py earthbound-access --id earthbound-access
python skills/snes-probar-lector/scripts/nuevo-proyecto.py illusion-access --id illusion-access
```

El creador rechaza destinos con archivos existentes. Esto solo prepara
infraestructura: no implementa todavía el lector de EarthBound o Illusion.
Si ya hay un proyecto, integra los archivos de `assets/runtime/` sin
sobrescribir su trabajo, conservando `tests/` y su identidad separada.

Completa `tests/project.json` para cada juego:

- `schema`: mantener `1`.
- `profile`: mantener `snes9x-lua-1.63-windows` para este gestor.
- `project_id`: identificador propio, como `earthbound-access`.
- `rom_path`: ROM local del juego; ruta absoluta o relativa a la raíz del proyecto.
- `rom_sha256`: SHA-256 de esa ROM exacta, incluida su traducción o cabecera.
- `emulator_dir`: instalación fuente que contiene `snes9x.exe`, `lua51.dll`,
  `lua5.1.dll` y `Valid.Ext`; se leen y copian, no se modifican.
- `config_template`: configuración funcional de ese fork, copiada al proyecto.

El creador acepta `--rom`, `--emulator-dir` y `--config-template` para
completar esos datos; con `--rom` calcula el hash. Sin ellos escribe valores
nulos y el gestor rechaza el arranque hasta completarlos.

```powershell
Get-FileHash -LiteralPath 'D:\mis-roms\mi-juego.sfc' -Algorithm SHA256
```

## Comprobar e iniciar un caso

Desde la raíz del proyecto creado:

```powershell
python -m unittest discover -s tests -p test_emulator_manager.py -v
& tests/emulador-pruebas.ps1 -Action Prepare
& tests/emulador-pruebas.ps1 -Action Start -Case smoke-check -Script smoke.lua -PrepareOnly
& tests/emulador-pruebas.ps1 -Action Stop
& tests/emulador-pruebas.ps1 -Action Start -Case smoke-check -Script smoke.lua
Get-Content tests/smoke-check/smoke.txt
& tests/emulador-pruebas.ps1 -Action Stop
```

La suite del gestor usa ROMs y binarios ficticios y no inicia un emulador.
`PrepareOnly` genera la copia y su configuración, sin ejecutar el binario.
El ensayo real empieza con el segundo `Start`, oculto y silenciado.
`smoke.lua` neutraliza botones de la copia, espera 120 fotogramas y produce
un recibo PASS, una captura de WRAM y, si la API lo permite, una imagen GD.
Esto demuestra el arranque del arnés, no lectura accesible ni progreso del juego.

El gestor ejecuta una copia verificada de la ROM como `emulator/Roms/game.sfc`.
El nombre genérico evita acoplar el autorun a un título. La configuración
redirige SRAM, estados, capturas, películas, SPC, parches y demás directorios
al caso; cada proyecto conserva su propio `base.conf`. Para personalizar un
caso, crea `<caso>/snes9x.conf` antes del arranque; se preserva el archivo fuente.
Las rutas con caracteres no representables por la configuración ASCII del
fork requieren validación adicional; los ensayos de esta entrega usaron rutas ASCII.

## Escribir las pruebas del lector

Los guiones Lua reciben:

```lua
assert(SNES_TEST_PROJECT == 'earthbound-access')
local root = assert(SNES_PROJECT_ROOT)
local out = assert(SNES_TEST_OUTPUT)
-- Cargar desde root..'source/' el módulo real del juego.
-- Guardar capturas y recibos bajo out, nunca junto a la ROM original.
```

No copies flags o coordenadas de Chrono. Declara preparación de RAM y usa
eventos nativos para verificar el resultado. Un caso que cargue lectores con
otro callback debe integrar la captura y comprobación en ese callback en vez
de reemplazarlo accidentalmente. `smoke.lua` es un ensayo independiente.

No se proporciona un archivo global de órdenes pendientes: cada juego y
caso define su canal cuando lo necesite y descarta órdenes antiguas al iniciar.

## Cerrar, archivar y verificar identidad

`Stop` comprueba propietario del proyecto, ruta del ejecutable, PID y hora
de creación antes de cerrar. Solicita cierre normal; si la copia no termina,
solo puede finalizar ese proceso verificado. Archiva y verifica por hash los
archivos del runtime. Conserva los guardados y capturas del caso.

Para un caso temporal, conserva el identificador `tmp-...` emitido y usa
`-Action Stop -Instance tmp-...` desde otra consola. `-Temporary` con arranque
real espera hasta su cierre. `Cleanup` recoge temporales ya cerrados, pero no
borra carpetas ajenas ni termina una sesión activa. El cierre funciona aunque
la ROM original o la instalación fuente ya no estén disponibles.

No copies ni distribuyas ROMs, guardados o sesiones privadas con el código.
El proyecto generado incluye `.gitignore`; guarda por separado los respaldos
y selecciona explícitamente qué capturas se convierten en fixtures de pruebas.

## Evidencia de esta implementación

Se verificaron dos gestores reales simultáneos en proyectos de ensayo A/B,
con una ROM local de Chrono como fixture. Ambos alcanzaron 120 fotogramas y
produjeron capturas de WRAM de 131072 bytes. Cerrar A dejó B y la instancia
habitual abiertos, y conservó un archivo de prueba en los guardados de B.
Después se cerró B. No se probó ninguna ROM de EarthBound o Illusion.

La suite comprueba dos identidades de juego, configuraciones y ROMs distintas,
hash incompatible, carpetas de otro propietario, rutas externas, PID ajeno,
archivo de evidencia temporal y conservación de guardados. El creador también
se prueba con destinos existentes y hash de ROM, sin modificar el original.
