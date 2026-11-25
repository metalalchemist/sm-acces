# Comprar y vender con lectura

El lector anuncia la opción Comprar o Vender seleccionada, el artículo y su precio, el dinero disponible y la cantidad de consumibles identificada. Conserva los nombres abreviados de la traducción del juego.

1. Habla con el tendero usando B. Si todavía te pide ir con el Viejo, continúa esa parte de la historia.
2. En la elección comercial, izquierda/derecha selecciona Comprar o Vender; B entra.
3. En la rueda, izquierda avanza y derecha retrocede. Deja aproximadamente medio segundo para que termine la animación y se lea la fila.
4. B abre la confirmación. Escucha el artículo; otro B confirma. Y cancela. Desde la rueda, Y vuelve al diálogo comercial.
5. Control F1 repite la última lectura comercial. Consultar no selecciona ni ejecuta una compra o venta.

«Cantidad en tu inventario» mide unidades que ya posees, no existencias del tendero ni una cantidad que hayas ordenado comprar. «Dinero» es el saldo actual en GP. «2 de 5» indica posición y tamaño de la lista. La confirmación todavía no significa operación realizada. El aviso de éxito requiere observar el cambio de dinero y del inventario.

## Comprobación y cobertura

La versión anterior se probó primero: comprando decía únicamente «Selección 1 de 5»; no leía el precio ni la pregunta de confirmación. Vendiendo reconocía algunos consumibles, pero no el precio ni el resultado comercial.

La prueba final `tests/shops10b-check` ejecutó entradas nativas en una copia silenciada de Snes9x Lua 1.63, con la ROM Sayans identificada por el proyecto. Se prepararon historia 11, 1000 GP y dos dulces en esa copia; se llegó a la tienda mediante transiciones nativas con posiciones preparadas. Esa preparación no demuestra completar naturalmente la historia ni jugar por oído.

| Operación nativa | Resultado |
| --- | --- |
| Recorrer la mercancía | Dulce 10 GP, Hierb Médica 10 GP, Copa Deseos 150 GP, Cinta 50 GP, Traje 20 GP |
| Confirmar primero la compra | Saldo todavía 1000 GP; sin compra anticipada |
| Comprar una hierba | 990 GP y una hierba añadida |
| Confirmar primero la venta | Saldo todavía 990 GP y dos dulces |
| Vender un dulce | 996 GP y un dulce restante |
| Cancelar otra venta | Saldo 996 GP e inventario conservado |

68 pruebas del lector real con Lua 5.1: PASS; 12 nuevas verifican filas, precios, cursores, confirmación, cambios reales capturados, cancelación, silencio, reapertura, datos inválidos, retraso del renderizador y Control F1. Registro: `tests/shops10-final-model-tests.txt`. Recibo: `tests/shops10b-check/receipt.json`; transcripción nativa: `shop.tsv`; inventario de código congelado: `frozen-inputs.json`.

El primer ensayo `shops10-check` ya comprobó las transacciones, pero mostró nombres antiguos al cambiar antes el cursor que el texto. Se conserva. La corrección espera 24 fotogramas estables y descarta la cabecera antigua mientras se construye la pregunta «¿Sí?». La repetición final utiliza esa versión exacta y elimina esos anuncios transitorios.

No se certifican aquí otras tiendas, ventas de armaduras equipadas, límite de dinero, falta de dinero, inventario lleno o mejora de armas. Los avisos de esas situaciones dependen del texto nativo y requieren sus propios ensayos. No se hizo escucha humana con NVDA; las pruebas de voz se limitaron al registro textual silenciado. Los otros submenús pedidos originalmente siguen pendientes, por la prioridad posterior de tiendas.

## Datos y reproducción

`source/shops.lua` observa 007D y 1847 (tienda 1 compra/2 venta), 180A/B (cursor/cantidad), 1812 (animación), 1803/1804 (pregunta/aviso), A1A4 (33 glifos renderizados), CC6A..CC6C (saldo), CC30..CC53 (inventario). Solo se considera una elección comercial cuando el diálogo nativo está en espera, hay dos opciones y las filas son exactamente Com/Vende. A1D7..A1D9 contiene sus posiciones; A173 selecciona la posición actual. No se deduce de botones.

La cantidad de compra de consumibles usa el identificador de la lista ROM D8:0000 + palabra 183C + cursor y los registros CC48..CC53. En venta de consumibles se exige que el número de registros coincida con la lista. Si no está identificada esa relación, se omite la cantidad. No se inventan cantidades de armaduras ni existencias del comercio.

El hook C07E62 exige `E2 20 A9 02 0C 03 18`, captura cancelación y deja la voz al tick central. El éxito exige cambio de inventario y saldo con sentido compatible; no atribuye éxito a una simple pulsación. El lector no escribe RAM ni envía controles.

```powershell
python 'SM access/tests/receipt-shops10.py'
```

Ese comando repite las pruebas de modelo y comprueba la evidencia congelada e integridad; no repite por sí mismo las operaciones del motor. Para un nuevo ensayo nativo, usa un caso nuevo con `prepare-shops10.py`, `shops10.lua` y el gestor propio de Mana, conservando el aislamiento del proyecto.

Referencias de investigación: código de [som-decomp](https://github.com/cidwel/som-decomp/tree/715885595c6917220726d437211a57b58f615fc1), descargado y enumerado por hash en `references/menus10/sources.json`. Sus direcciones se contrastaron con esta ROM y las capturas; no son interfaces de otros juegos.

## Activación y reversión

No había sesión habitual abierta al terminar. Los cambios se cargan al próximo inicio de `iniciar-lector.cmd`. Se cerraron únicamente las copias identificadas por el gestor; nueve archivos protegidos mantuvieron sus hashes. No se tocaron ROM, partidas ni configuración del jugador.

Respaldo: `backups/antes-menus-10.zip`. Para revertir esta unidad, recuperar únicamente `source/reader.lua` y `source/menus.lua` de ese ZIP y apartar `source/shops.lua`. No restaurar partidas, ROM ni toda la carpeta. La investigación y los ensayos pueden conservarse como evidencia.
