---
name: snes-investigar-memoria
description: "Trigger: accesibilizar SNES, Super Nintendo, investigar ROM o RAM. Identifica estados y rutinas nativas para un lector accesible."
license: Apache-2.0
metadata:
  author: VeMovie
  version: "1.1"
---

## Activation Contract

Activa al iniciar la accesibilidad de un juego SNES o investigar una función sin direcciones verificadas.

Aplica la [base general de videojuegos](../juegos-accesibles/SKILL.md) y conserva esta especialización SNES.

## Hard Rules

- Identifica juego, traducción, hash, mapper, cabecera, emulador y API antes de reutilizar direcciones.
- Trata las direcciones de Chrono como ejemplos específicos, nunca como una interfaz SNES universal.
- Separa observación de producción y preparación de pruebas. No investigues con escrituras en la partida habitual.
- Declara las hipótesis; no conviertas coincidencias de pantalla o RAM en hechos confirmados.

## Decision Gates

| Necesidad | Preferencia |
| --- | --- |
| Cursor, evento o texto disponible en el motor | Observa la rutina y sus datos nativos. |
| Dirección desconocida | Compara capturas controladas y contrasta el desensamblado. |
| Variante de ROM incompatible | Deshabilita solo el módulo afectado; no instales sus hooks. |

## Execution Steps

1. Lee la continuación vigente; identifica el comportamiento solicitado y un caso reproducible.
2. Registra capacidades del fork y restricciones de callbacks en la [ficha de investigación](references/investigacion.md).
3. Captura antes/después, incluye un caso negativo y demuestra qué dato cambia por la acción.
4. Verifica ancho, signo, endianidad, escala, punteros, centinelas y contexto de cada dato.
5. Captura datos temporales dentro del hook adecuado; comprueba sus bytes de firma antes de registrarlo.
6. Registra capacidades y controles propios; no traslades atajos ni tipos de combate de otro juego.
7. Entrega el contrato del adaptador al lector, mapa o prueba correspondiente.

## Output Contract

Entrega identidad compatible, tabla de datos con procedencia, firmas, hipótesis descartadas, captura reproducible y límites. No anuncies accesibilidad completa por haber localizado un byte.

## References

- [Investigación y contrato por juego](references/investigacion.md): abrir antes de instrumentar.
