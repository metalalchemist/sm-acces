# Cómo accesibilizar esta copia de Secret of Mana

La primera entrega jugable debe leer inicio, nombre y diálogos. Después debe cubrir el menú circular y el estado del grupo; la orientación y los avisos de combate requieren validar actores, terreno y colisiones en esta traducción. Tenemos evidencia nativa del texto inicial y del prólogo, no de un combate accesible.

## Identidad y entorno

| Dato | Resultado local |
| --- | --- |
| Archivo | `Secret of Mana (U) [T+Spa102_Sayans].smc` |
| Traducción | El nombre declara Sayans 1.02; no se recibió el parche ni su documentación para autenticar la autoría/versionado |
| Título interno | `Secret of Mana (Esp)` |
| Tamaño | 2.097.152 bytes, sin cabecera de copiador |
| SHA-256 | `70f29ff2870171601333272f64a1b7f8040de3c137f336b7afcc97ec679951ad` |
| CRC32 | `14854546` |
| Mapper | Cabecera `21`: HiROM, tipo `02`, región `01`, revisión interna `00` |
| SRAM declarada | Exponente 3: 8 KiB |
| Checksum | Guardado `51FC`, complemento `AE03`; suma local `10B5`. No coincide, por lo que no sirve para autenticar esta traducción; el SHA-256 identifica la copia ensayada |
| Emulador | Instalación local `Snes9x-Lua-1.63/snes9x-lua-1.63-win32-x64`, copiada por el gestor |
| API ejercitada | Lua, `emu.registerbefore/registerafter`, `joypad.set`, `memory.readbyte/readword/readbyterange/getregister/registerexec`, `gui.gdscreenshot` |
| Soporte preparado | DLL de audio y voz de Chrono; no cargadas ni certificadas para Mana |

Para esta ROM sin cabecera, en bancos C0–DF la conversión estática HiROM es `offset = ((banco - C0) << 16) | dirección16`. Ejemplo: `C017CE` corresponde a `0x17CE` del archivo. WRAM `7E` y `7F` no son offsets de ROM ni direcciones de Windows. La estructura local de las tablas de mapas examinadas y los bytes del parser son consistentes con esa conversión.

El perfil mantiene Snes9x y el control habitual como punto de partida. El arnés neutraliza las entradas externas de su copia y genera botones SNES propios; no altera los controles guardados del jugador.

## Lo observado en el motor

El caso `smoke-check` llegó a 120 fotogramas y volcó los 131.072 bytes de WRAM. No demuestra que el juego ya hubiera terminado de arrancar: en los primeros fotogramas hay valores de inicialización `55`.

`research-check` recorrió 1.800 fotogramas: Start en 360, B en 600, Start en 900 y B en 1.200, cada pulsación durante cuatro fotogramas. Capturó 407 llamadas al emisor de glifos. Se detuvo en la pantalla de nombre: Start con nombre vacío no completó el inicio. Se conserva este intento como evidencia, no como progreso de campo.

`native-start-check` repitió el inicio con B en 900 para introducir A y Start en 1.200 para continuar. Después emitió pulsaciones B espaciadas. Llegó a 3.600 fotogramas y 751 llamadas al emisor. Entró de forma nativa en el prólogo (mapa candidato 179, HP candidato 50); no llegó a campo libre ni a enemigos. No hubo escrituras de RAM ni carga de estados preparados.

El hook observa `C017CE`, antes de `STA $A1A4,X`. Comprueba primero `9D A4 A1 E8 EE CE A1`. Captura A reducido a ocho bits y X dentro del hook. El estado de anchura documentado por la fuente estadounidense es M8/X16; la observación local demuestra glifos e índices coherentes en estas pantallas, sin certificar todos los llamadores.

Se obtuvieron «BIENVENIDO A SECRET OF MANA.» y las instrucciones del nombre. En el prólogo la tabla inglesa produjo errores concretos: `Man[` y `h]roe`, y `C7` como desconocido. Las imágenes y el flujo de glifos permiten confirmar **C3=á, C4=é, C7=ó** en esta ROM. Se guardan en `source/charset-observed.json`. Aún faltan í, ú, ñ y otros símbolos. La transcripción `text-hypothesis.json` conserva deliberadamente la hipótesis inglesa inicial para mostrar dónde falla; no es la transcripción española definitiva.

La repetición sin pulsaciones entre cambios de pantalla no añadió nuevas líneas al registro. Esto valida el uso del emisor como observador en esas pantallas, no la deduplicación de un lector futuro. Los menús y las instrucciones también pasan por el emisor: no se puede etiquetar cada llamada como diálogo de campo.

## Contrato de datos: confirmado y candidato

Las direcciones de esta tabla son del bus SNES. Salvo la fila del emisor, sus significados siguen siendo candidatos procedentes de la investigación estadounidense; una captura coherente no sustituye a una prueba controlada por campo. La columna ES de `wram-companion-map.md` corresponde a **Magno**, no a esta traducción Sayans.

| Dato | Dirección, ancho y representación | Validez y siguiente comprobación |
| --- | --- | --- |
| Glifo final | Hook `C017CE`; A bajo, X índice; destino `7EA1A4+X` | Confirmado en inicio, nombre y prólogo; faltan pausas, cierres, sustituciones y elecciones |
| Mapa | `7E00DC`, u16 little-endian | Observado 179 en prólogo; contrastar transiciones de campo y pantalla |
| Evento | `7E00D0`, u8 | Cambia durante prólogo; falta separar diálogo, escena y control recuperado |
| Menú circular | `7E007D`, u8; candidato 1 abierto | No validado: abrir, cerrar y distinguir submenús |
| Dueño/categoría/cursor/cantidad | `7E1808..180B`, u8 cada uno; ocupación `7E1812` | RAM residual incluso en inicio; exigir contexto, límites y animación terminada |
| Personajes | `7EE000 + slot*0200`, slots 0..2 | Presencia `+000`, identidad `+1E7`, estado `+190` u16; falta probar compañeros y cambio de control |
| Posición | Registro `+002/+004`, u16 little-endian, píxeles según fuente | Se mueve durante escena; no interpretarlo como movimiento controlado. Faltan una acción y un caso negativo en campo |
| Vida y magia | `+182/+184` u16 HP/máximo; `+186/+187` u8 MP/máximo | HP 50 coherente con inicio; falta daño, curación y cambio de personaje |
| Arma y recarga | `+1E4` u8 tipo; `+1E8` fila; `+1ED` u8 recarga, 0 lista según fuente | Verificar equipar, golpear, recuperar y cargar por separado |
| Actores enemigos | Fuente propone slots 3..5 para enemigos ordinarios; otros objetos/jefes requieren estudio propio | No clasificar todos los slots restantes como enemigos; presencia, tipo y muerte pendientes |
| Caja atacante/cuerpo | Actor `+0C0..0C3` / `+0C8..0CB` | Formato, signo, origen y desfase temporal pendientes de verificación local; no instaladas como detector |
| Terreno | Capas `7F0000`/`7F4000`; atributos `7FB800`/`7FBC00`; actor `+00B` y `+08E` | Direcciones de fuente, pendientes de contraste con paredes, pendientes, alturas y puentes locales |

Las tablas de archivo `0x84000`, `0x85000`, `0x87000` y `0x83000` son pistas para eventos, composición, entidades y transiciones. Los bytes iniciales de la tabla `0x85000` coinciden con el ejemplo publicado de mapas (`02 54 0E 54 1A 54...`). Esto no valida el contenido completo ni las condiciones de todas las salidas.

No instalar hooks solo por coincidir el título. El lector deberá comprobar el hash soportado y firmas locales de cada módulo, e invalidar únicamente el módulo incompatible. Los valores de menú sin contexto ya dieron un caso negativo útil: dueño/cursor 92 en pantallas que no son la rueda.

## Diseño del lector

Separar `adapter`, texto, menús, estado, mapa, combate y presentación. Un único callback de fin de fotograma coordina lecturas y voz; los hooks solo capturan eventos pequeños en una cola acotada. Prism y el mezclador existentes son reutilizables como infraestructura, sin trasladar direcciones de Chrono. Registrar un arranque nuevo antes de afirmar activación.

El texto necesita páginas, pausas, cierre, nombres y números resueltos, repetición a petición y registro de códigos desconocidos. El nombre requiere cursor propio, letra seleccionada, texto escrito y confirmación. Ver texto no demuestra que la selección sea accesible.

La rueda debe anunciar personaje dueño, categoría, selección, cantidad/coste y objetivo. Su animación no debe repetir anuncios. Usar un objeto o magia exige diferenciar selección de resultado efectivo; HP/MP y efectos pueden cambiar después del cierre. Tiendas, equipo, guardado y opciones necesitan contratos propios.

La orientación debe consultar personaje controlado, posiciones vivas y terreno actual. Ofrecer selección de personas, objetos y salidas; dirección y distancia directa primero, ruta únicamente con colisiones y meta de interacción verificadas. En Mana el combate ocurre en el campo: suspender el radar enemigo durante todos los combates anularía su utilidad. Suspenderlo en menús, escenas o pérdida de contexto, conservando señales de peligro durante campo controlable.

## Radar y alcance de ataques

En el archivo publicado de Zelda1Access 2.1, `Data/nT9wK2bX6jHsR.lua` implementa:

- `update_enemy_radar`: enemigo fijado o, si no existe, el más cercano; excluye ciertos contextos y protege el sonido inicial.
- `pan_bucket`: posición X absoluta en pantalla, cuantizada; no es un cálculo de distancia respecto a Link.
- `enemy_pitch`: tono según Y de la cuadrícula. Cadencias configurables de 30, 24, 18, 12 y 10 fotogramas.

Tomar selección estable, ajustes de volumen, radar de un objetivo y familias sonoras distintas como ideas. Para Mana preferir dirección respecto al personaje controlado y coordenadas de mundo: su cámara móvil y grupo de tres hacen insuficiente copiar la fórmula de pantalla. El puente binario de sonido no se ejecutó. No se incorporó código Zelda al lector ni se asumió una licencia de dominio público. Las funciones de congelar enemigos y autoorientar alteran el juego; no se incluyen en este estudio de lectura.

Propuesta de señales, aún sin activar:

| Señal | Significado exigido |
| --- | --- |
| Pulso enemigo | Ubicación y cercanía; jamás equivale a impacto seguro |
| Arma disponible | Transición real de recarga a lista; carga especial por separado |
| Alcance ofensivo | El ataque normal compatible podría solapar el cuerpo vulnerable del objetivo; indicar incertidumbre hasta validar predicción |
| Amenaza inmediata | Caja ofensiva activa enemiga o proyectil relevante frente al cuerpo vulnerable del jugador |
| Daño/resultado | Evento o variación nativa; distinguir fallo, bloqueo, daño y muerte |

Empezar por espada y un conejo enemigo del inicio, cuatro orientaciones, reposo/ataque/retirada y distancias dentro/fuera del borde. Contrastar cajas, estado de ataque, altura/capa, invulnerabilidad y frame anterior. La fuente documenta cambios de caja durante el golpe y comprobaciones sobre cajas del fotograma previo: la distancia euclídea sola no es un alcance fiable. No usar el umbral de decisión de IA como radio de daño. Proyectiles, magias, jefes y ataques cargados necesitan módulos y pruebas separados.

Leer estado cada fotograma para no perder ataques breves; reproducir señales con límites de repetición y prioridades ajustables. Se puede empezar ensayando radar de baja cadencia, pero los dos sondeos por segundo de proximidad en Chrono no bastan como detector temporal de ataques. La voz tiene prioridad; evitar un coro de todos los enemigos a la vez.

## Sonidos y soporte local

`runtime/assets.json` registra procedencia y hashes de copias autorizadas de los WAV y soporte de Chrono. No se afirmó que esos sonidos sean de dominio público. Quedan preparados para probarlos con Mana; ningún sonido nuevo es necesario para esta fase sin reproducción.

No se descargaron sonidos externos ni se ejecutó FFmpeg. Si hacen falta timbres adicionales al probar combate, elegir CC0/dominio público con licencia y URL del archivo conservadas. Recortar y convertir después con FFmpeg a PCM s16le, mono, 22050 Hz, con fundidos breves. Conservar original, atribución/licencia, comando exacto y SHA-256. La duración de un pulso y su volumen se deciden por escucha y por no tapar voz o sonidos del juego.

## Fuentes y alcance de su autoridad

- [som-decomp](https://github.com/cidwel/som-decomp), commit fijado en `references/sources.json`: copias locales de texto, WRAM, menús, armas, enemigos y mapas. Se conserva su licencia GPL-3.0. Sus verificaciones son del proyecto fuente y no resultados nuestros con Sayans.
- [Mapas de Expanding Secret of Mana](https://hackofmana.com/maps/): tablas y registros de mapas. Consulta web, sin atribuir validación nativa local a su documentación.
- [Zelda1Access 2.1](https://github.com/GADeuvall2000/Zelda1Access/releases/tag/Zelda1Accessv2.1): el ZIP está enlazado dentro del cuerpo de la publicación; su lista de assets de API está vacía. Metadatos, índice y SHA-256 conservados. Solo se extrajeron código y documentación como referencia, no ejecutables, ROMs ni sonidos.
- `../chrono-access/continuar chrono.md` y documentación de texto/audio: contexto de operación, Prism, API y separación de pruebas; ninguna dirección de Chrono se aplica a Mana.

Las skills utilizadas fueron investigar memoria, probar lector, leer texto/menús, orientar mapas, diseño documental y unidades de trabajo. No se aplicó asistencia automática de desafíos.
