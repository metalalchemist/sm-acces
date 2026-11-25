---
name: snes-probar-lector
description: "Trigger: pruebas SNES, Snes9x, recargar lector o validar accesibilidad. Aísla partidas y distingue evidencia simulada, nativa y auditiva."
license: Apache-2.0
metadata:
  author: VeMovie
  version: "1.2"
---

## Activation Contract

Activa para ensayar, verificar, entregar o recargar un lector accesible de SNES.

Aplica la [base general de videojuegos](../juegos-accesibles/SKILL.md) y conserva esta especialización SNES.

## Hard Rules

- Identifica proceso, ruta y sesión antes de operar; usa copias aisladas y silenciadas para inyectar entradas o RAM.
- Conserva ROM, guardados y configuración habituales. Un cambio concurrente de hash no autoriza restaurarlos.
- No sobrescribas una DLL cargada ni anuncies recarga por el simple éxito de un clic.
- No equipares tests, mezcla silenciada, recorrido nativo y valoración humana con NVDA.
- Crea un documento propio por entrega o corrección; la continuación contiene solo un resumen enlazado para retomar.

## Decision Gates

| Comprobación | Evidencia requerida |
| --- | --- |
| Modelo/lector | Módulo real, capturas y casos negativos. |
| Acceso jugable | Botones procesados por el motor y estado final nativo. |
| Audio | PCM, llamadas al mezclador y escucha separada si ocurrió. |
| Activación | Inicio nuevo verificable en log; si falta, declarar pendiente. |

## Execution Steps

1. Lee [aislamiento y entrega](references/pruebas.md); respalda la unidad e inventaría archivos protegidos.
2. Para otro juego, crea su gestor con [nuevo-proyecto.py](scripts/nuevo-proyecto.py) y completa su manifiesto siguiendo [proyectos independientes](references/proyectos-independientes.md). No ejecutes el gestor de Chrono con otra ROM.
3. Redirige SRAM, savestates y registros; descarta órdenes históricas antes de abrir el arnés.
4. Ejecuta sintaxis y pruebas pertinentes, luego el escenario nativo que justifique el cambio.
5. Congela y ejecuta código exacto del ensayo; registra módulos, configuración y hashes, no solo una ruta mutable.
6. Archiva capturas, preparación y resultados, incluidos intentos fallidos.
7. Cierra solo la copia identificada; restaura entradas del arnés antes de la suite que gestiona emuladores.
8. Escribe el documento de la entrega con cobertura/reversión y enlázalo desde un resumen breve en la continuación. Recarga la sesión habitual únicamente dentro del alcance autorizado y verifica el log.

Comprueba ventana visible, foco, conmutación entre aplicaciones, controles conservados y comprensión con el jugador.

## Output Contract

Entrega el documento propio y el [recibo](assets/recibo.md), integrado o enlazado, con comandos/resultados, escenario, integridad, procesos, activación y límites. Enlaza el documento desde la continuación. No inventes una prueba omitida ni reutilices un conteo histórico como resultado actual.

## References

- [Pruebas, protección y recarga](references/pruebas.md): abrir antes de ejecutar el arnés.
- [Gestor independiente por juego](references/proyectos-independientes.md): crear y comprobar EarthBound Access, Illusion Access u otro proyecto.
