---
name: snes-orientar-mapas
description: "Trigger: mapas SNES, referencias, rutas, colisiones, objetos o vehículos. Añade orientación espacial desde terreno y eventos nativos."
license: Apache-2.0
metadata:
  author: VeMovie
  version: "1.1"
---

## Activation Contract

Activa al hacer localizables salidas, personas, mecanismos, tesoros o transportes de un juego SNES.

Aplica la [base general de videojuegos](../juegos-accesibles/SKILL.md) y conserva esta especialización SNES.

## Hard Rules

- Distingue distancia directa, ruta transitable y alcance real de interacción.
- Sigue presencia y posición nativas; no inventes referencias por el aspecto de un sprite.
- Consulta flags actuales; no mantengas un historial propio de botones para deducir puertas o cofres.
- Conserva capas, sectores, entradas, unidades y modos de movimiento del juego.

## Decision Gates

| Objeto | Representación |
| --- | --- |
| Mueble fijo comprobado | Caja anotada y justificada por evidencia. |
| Persona, vehículo o objeto móvil | Identidad estable, coordenadas vivas y presencia contextual. |
| Parpadeo o escena | Investiga procesamiento, tipo y flags; dibujo no siempre significa presencia. |
| Cortable, rompible o recogible | Verifica atributo, herramienta, orientación, alcance y retirada tras interactuar. |
| Transporte o acceso por contacto | Reproduce su condición nativa; no asumas puerta ni botón A. |

## Execution Steps

1. Lee [mapas y señales](references/mapas.md); identifica mapa, control, escala y capa.
2. Añade un perfil pequeño respetando orden de prioridad y generadores existentes.
3. Expón selección, dirección y distancia; calcula rutas con terreno y meta de interacción comprobados.
4. Vincula estado/presencia al motor y clasifica actores de escena para evitar personas falsas.
5. Suspende proximidad fuera de contexto; observa choques reales sin inferirlos solo de quietud.
6. Comprueba avance/regreso después de peleas y recogidas; conserva objetivo estable y revisa todas las amenazas.
7. Prueba ambos lados de accesos, cambios de historia, desaparición y transición nativa.

## Output Contract

Entrega referencias seleccionables, instrucciones de interacción, estado y evidencia de acceso. Enumera mapas, variantes y recorridos realmente comprobados; separa fórmulas simuladas de caminatas nativas.

## References

- [Mapas, presencia y audio](references/mapas.md): abrir antes de añadir un perfil.
