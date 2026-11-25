---
name: juegos-accesibles
description: "Trigger: accesibilizar juegos, accesibilidad de videojuegos, lector o radar de juego. Define el método general y elige adaptadores por plataforma."
license: Apache-2.0
metadata:
  author: VeMovie
  version: "1.0"
---

## Activation Contract

Activa al iniciar o ampliar accesibilidad de cualquier videojuego nativo o emulado. Carga esta base y solo las especializaciones necesarias.

## Hard Rules

- Conserva progreso, controles y preferencias; investiga en sesiones aisladas.
- Verifica versión, fuente de datos y capacidades. No impongas direcciones SNES, Lua, NVDA ni un emulador a otros juegos.
- Distingue hipótesis, previsión, acción y resultado confirmado; prioriza estado semántico observable.
- Conserva los atajos de cada proyecto. Consultar no cambia selección ni rutas silenciosamente.
- Separa lectura/orientación de ejecución automática, que requiere solicitud y activación explícitas.
- Documenta cada entrega, incluidas correcciones pequeñas, en un archivo propio; deja en la continuación solo un resumen para retomar y un enlace al documento.

## Decision Gates

| Situación | Adaptación |
| --- | --- |
| API, árbol accesible, eventos o mod | Evalúa estado semántico, versión y cobertura. |
| Emulación | Identifica consola y API; carga especialización compatible. |
| Combate por menús | Lee selección, costes, ejecución y resultado. |
| Acción en tiempo real | Prioriza señales de alcance/peligro según preferencias. |
| Dato no observable | Declara el límite; no inventes presencia o resultados. |

## Execution Steps

1. Completa la [ficha por juego](assets/ficha-juego.md) y define pruebas sin alterar la sesión habitual.
2. Sigue los [contratos generales](references/contratos.md) para controles, lectura, interacción, exploración y audio.
3. Implementa una función concreta con adaptador propio; usa las [especializaciones](references/plataformas.md) solo donde correspondan.
4. Comprueba selección estable, desaparición, regreso, siguiente destino y salida de cobertura.
5. Valida controles, ventana/foco y comprensión de señales con el jugador.
6. Conserva código exacto, preparación y resultados; escribe el documento de la entrega con activación/reversión y enlázalo desde la continuación según los contratos generales.

## Output Contract

Entrega función utilizable, controles inequívocos, cobertura y evidencia separada de modelo, motor, audio y uso humano. Incluye el documento propio de la entrega y su resumen enlazado en la continuación. Declara pendientes sin convertir una prueba preparada en recorrido completo.

## References

- [Contratos reutilizables](references/contratos.md).
- [Adaptación por plataforma](references/plataformas.md).
- [Ficha de trabajo](assets/ficha-juego.md).
