# Integración por plataforma

La base general define comportamiento y comprobación. Cada adaptador aporta estados, eventos, unidades, entidades, controles y capacidades de voz/audio de su juego.

| Fuente | Comprobar |
| --- | --- |
| Accesibilidad integrada | Árbol accesible, eventos, foco y pantallas cubiertas. |
| API de mods/plugin | Versiones, ciclo de vida, tipos de entidad e instalación reversible. |
| Logs/protocolo/archivos | Actualización, retraso y contexto; no usar datos residuales. |
| Emulación/memoria | Versión, dominios, endianidad, escalas, productor y API real. |
| Imagen/OCR | Idioma, resolución, animación y confianza; preferir estado semántico disponible. |

Para SNES carga solo lo necesario:

- [Investigar memoria](../../snes-investigar-memoria/SKILL.md).
- [Leer texto y menús](../../snes-leer-texto-menus/SKILL.md).
- [Orientar mapas](../../snes-orientar-mapas/SKILL.md).
- [Probar el lector](../../snes-probar-lector/SKILL.md).
- [Asistir desafíos](../../snes-asistir-desafios/SKILL.md), solo para ejecución solicitada.

Para otro sistema crea su adaptador. No ejecutes el gestor Snes9x con otra plataforma ni reutilices direcciones de Chrono sin investigación. Los ejemplos existentes ilustran métodos; no aportan datos, recursos ni controles universales.
