---
name: snes-asistir-desafios
description: "Trigger: ayuda opcional, minijuegos o desafíos SNES inaccesibles. Diseña asistencia cancelable con entradas nativas y contexto verificado."
license: Apache-2.0
metadata:
  author: VeMovie
  version: "1.1"
---

## Activation Contract

Activa cuando el usuario solicite asistencia de ejecución para un desafío concreto, no por necesitar orientación o lectura.

Aplica la [base general de videojuegos](../juegos-accesibles/SKILL.md) y conserva esta especialización SNES.

## Hard Rules

- Mantén observación e instrucciones separadas de la ayuda que pulsa botones.
- Inicia la asistencia con una acción explícita del jugador; no la actives al entrar en una sala.
- Ejecuta botones del juego, no teletransportes, cambios de historia ni guardados para simular éxito.
- Cancela y libera entradas ante contexto incompatible, bloqueo o petición del usuario.

## Decision Gates

| Necesidad | Resultado |
| --- | --- |
| Conocer el estado o el camino | Lectura/orientación; ninguna entrada inyectada. |
| Escuchar instrucciones | Voz; no inicia la ayuda. |
| Ejecutar un desafío autorizado | Máquina de estados acotada, comprobada en copia aislada. |

## Execution Steps

1. Conserva atajos por proyecto y separa consultas de órdenes que cambian ruta u objetivo.
2. Lee [asistencia y controles](references/asistencia.md); comprueba atajos y asignaciones reales.
3. Define precondiciones nativas, estados, límites, reintentos y condición observable de éxito.
4. Añade inicio, cancelación e instrucciones independientes con detección por flanco.
5. Maneja transiciones esperadas sin convertir posiciones temporalmente inválidas en éxito.
6. Prueba no activación, cancelación, menú, combate, firma incorrecta, bloqueo y finalización.
7. Recorre el desafío con botones en la copia; libera controles y anuncia solo el resultado confirmado.

## Output Contract

Entrega alcance exacto, controles, estado final, límites y evidencia nativa. Declara por separado recuperaciones solo simuladas y evaluación pendiente con NVDA.

## References

- [Ayudas y conflictos de entrada](references/asistencia.md): leer antes de implementar o cambiar atajos.
