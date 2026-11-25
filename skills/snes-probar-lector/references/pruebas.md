# Probar y entregar sin alterar la partida habitual

## Aislamiento

Identifica el ejecutable exacto, PID y momento de inicio; no reutilices un PID anotado en una entrega antigua. Inspecciona configuración y órdenes pendientes. La copia de pruebas debe escribir SRAM, estados, capturas y registros en su propio caso. No basta con copiar el ejecutable si sus directorios siguen apuntando a los guardados del usuario.

Respalda únicamente los archivos de la unidad y las entradas temporales del arnés. Inventaría hashes de los archivos protegidos al empezar y compararlos al terminar. Si el usuario sigue jugando, conserva cualquier guardado nuevo; registra la diferencia y no atribuyas autoría solo por el hash. Un archivo ignorado por Git tampoco es un respaldo.

No elimines una carpeta recursivamente sin validar su ruta, propiedad y archivo previo de evidencia. No cierres una instancia habitual para que un ensayo resulte más cómodo. Si no puedes identificar inequívocamente la copia o su salida de datos, resuelve ese aislamiento antes de lanzar escrituras de prueba.

## Capas de evidencia

1. **Sintaxis:** los archivos cargan con la versión real de Lua y sus dependencias.
2. **Modelo:** RAM/ROM capturadas y variantes simuladas prueban interpretación, límites, máscaras y centinelas.
3. **Lector integrado:** hooks, callback central, mensajes y silencio se prueban usando producción, no una reimplementación de su lógica.
4. **Motor:** entradas nativas activan un mecanismo, cruce, abordaje, menú o combate; el estado final verifica el resultado.
5. **Audio:** PCM no nulo y mezcla real silenciada verifican el recorrido de audio, no una escucha humana.
6. **Uso real:** NVDA y control habitual permiten valorar comprensión, sobrecarga sonora y orientación efectiva.

Registra preparación de RAM, historia, posición e inventario. Preparar el estado de una sala no demuestra el combate anterior ni un recorrido natural completo. Prueba reposo, menú, cancelación, otro mapa, firma errónea y reapertura cuando sean pertinentes. Preserva fallos iniciales y delimita cuáles escenarios terminaron en PASS.

## Comandos existentes para Chrono

Para un juego nuevo, usa primero el [gestor independiente](proyectos-independientes.md).
Su código fuente está incluido en esta skill y se copia dentro de cada proyecto.
Los comandos de esta sección son únicamente ejemplos del proyecto histórico de Chrono.

Desde la raíz de VeMovie, tras leer el guion seleccionado:

```powershell
& tools/chrono-access/test/emulador-pruebas.ps1 -Action Prepare
& tools/chrono-access/test/emulador-pruebas.ps1 -Action Start -Case race-check -Script discover-race.lua
& tools/chrono-access/test/emulador-pruebas.ps1 -Action Stop
venv/Scripts/python.exe -m pytest tools/chrono-access/test/test_epoch94.py -q
```

Son rutas y casos de Chrono, no una orden para iniciar ese juego en otra tarea. El gestor admite una sesión compartida y casos temporales identificados; inspecciona sus parámetros antes de usarlos. Ejecuta primero pruebas enfocadas. Cierra el ensayo antes de una suite que pruebe el propio gestor. Los ocho fallos históricos de `test_walk_trace` documentados en la continuación no autorizan cambiar la política de diagnóstico ni afirmar que siguen siendo el resultado actual.

## Activación y reversión

Cambiar Lua en disco no cambia el script ya cargado. Una DLL nativa cargada requiere un ciclo de descarga/cierre permitido, no sobrescritura en caliente. Para recargar Lua, verifica una consola única del lector y una confirmación nueva de inicio en el log. Si falla o no existe emulador abierto, declara «disponible al siguiente inicio», sin cerrar ni cargar una partida por tu cuenta.

Escribe cada entrega o corrección en su propio documento numerado, dentro de la carpeta de documentación del juego. Reúne uso/controles, cambios, resultado y límites, evidencias y recibo, activación, pendientes, respaldo y reversión que preserve entregas anteriores. Aplica el [contrato de un documento por entrega](../../juegos-accesibles/references/contratos.md#un-documento-por-entrega).

Actualiza la continuación como punto de entrada: resumen breve de la entrega y enlace «Lee…» al documento completo, siguiendo la organización de `continuar chrono.md`. No vuelques allí el informe detallado del ensayo ni migres el historial anterior sin petición expresa. No publiques «completo» si solo comprobaste fórmulas simuladas. La valoración con NVDA puede quedar pendiente explícitamente.

## Fuentes locales

- [Gestor de pruebas](../../../chrono-access/documentación/23-emulador-compartido-de-pruebas.md).
- [Lua real en tests](../../../chrono-access/test/test_reader.py).
- [Recarga confirmada](../../../chrono-access/documentación/89-recarga-confirmada-del-lector.md).
- [Estado actual y protección](../../../chrono-access/continuar%20chrono.md).

## Código reproducible y comprensión

Congela arnés y módulos antes del ensayo y ejecuta esa copia o verifica su identidad durante la ejecución. El gestor plantilla conserva el script de entrada como `executed-script.lua`; no congela automáticamente sus dependencias: archívalas también. No reutilices esa cobertura como prueba de módulos cambiados después.

Comprueba ventana visible, Alt-Tab/foco en Windows y controles preservados. Valida un ciclo de selección, aproximación, interacción y continuación/regreso con el jugador. Registra comprensión y confusiones, además de resultados automáticos. Usa la [ficha general](../../juegos-accesibles/assets/ficha-juego.md) para catálogo sonoro y controles de cada proyecto.
