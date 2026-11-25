---
name: snes-leer-texto-menus
description: "Trigger: diálogos, menús, combate, voz o NVDA en juegos SNES. Lee texto y selecciones desde el estado nativo del juego."
license: Apache-2.0
metadata:
  author: VeMovie
  version: "1.1"
---

## Activation Contract

Activa para leer diálogos, decisiones, inventario, equipo, combate o selectores de un juego SNES.

Aplica la [base general de videojuegos](../juegos-accesibles/SKILL.md) y conserva esta especialización SNES.

## Hard Rules

- Observa el cursor y contexto nativos; no deduzcas selecciones de teclas o botones físicos.
- Captura en hooks; emite voz fuera de ellos, desde la integración central por fotograma.
- Usa el charset de la ROM soportada y respeta información que el juego aún no revela.
- No confirmes acciones por el usuario. Distingue selección, preparación, ejecución y resultado.

## Decision Gates

| Contexto | Técnica |
| --- | --- |
| Texto comprimido con sustituciones | Captura glifos o texto ya resuelto por el motor. |
| Lista o decisión | Lee cursor, límites y fila completa después de actualizarse. |
| Acción en tiempo real | Usa señales de alcance/recuperación/peligro según preferencia; evita voz continua de orientación. |
| Texto idéntico en una visita nueva | Permite releerlo; deduplica dentro del contexto actual. |

## Execution Steps

1. Obtén datos y firmas verificados mediante investigación por juego.
2. Sigue las [reglas de lectura](references/lectura.md); separa campo, menú y combate.
3. Distingue recuperación de potencia, posibilidad de ejecutar y resultado; no llames impacto a una previsión de alcance.
4. Modela entrada, cambio de selección, confirmación, cancelación y salida.
5. Expón lectura como `tick`; integra hooks compartidos sin reemplazar otros observadores.
6. Prueba cambios, reposo, reapertura, animación, paginación, símbolos desconocidos y contexto inválido.
7. Valida el módulo real en la copia aislada y distingue el registro textual de la escucha con NVDA.

## Output Contract

Entrega lector integrado, firmas, transcripciones y pruebas de silencio/deduplicación. Declara pantallas cubiertas, fuentes de datos y operaciones todavía no verificadas.

## References

- [Lectura y voz](references/lectura.md): consultar al diseñar el estado del lector.
- [Lector mínimo adaptable](assets/lector-observado.lua): usar solo tras definir su adaptador y rutina.
