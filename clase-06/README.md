# Clase 6 · El Motor Reactivo

## Objetivo
Entender cómo Shiny escucha los inputs y recalcula solo lo necesario. Escribir el filtro una vez y reutilizarlo. Controlar cuándo se recalcula algo y manejar errores comunes.

## Qué hace la app
Los mismos filtros de la clase anterior, pero el server calcula la tabla filtrada una sola vez con `reactive()`. Un contador y una bitácora muestran cuándo se recalcula. Un botón dispara un cálculo bajo demanda (departamentos reñidos) y otro reinicia los filtros.

## Componentes que se explican en clase
| Componente | Para qué sirve |
|---|---|
| `reactive()` | Un valor que se recalcula solo cuando cambia un input que usa. Se llama como función, `datos_filtrados()`. |
| `req()` | Frena el cálculo, sin error, si falta un input. |
| `validate(need())` | Muestra un mensaje amable en lugar de un error rojo. |
| `eventReactive()` | Recalcula solo cuando ocurre un evento (un botón). |
| `observeEvent()` | Ejecuta una acción ante un evento. No devuelve valor. |
| `update*Input()` | El server cambia un control de la ui. |
| `isolate()` | Lee un valor reactivo sin depender de él. |
| `reactiveVal()` | Una variable reactiva propia del server. |

## Cómo correr la app
Abrí `app.R` en RStudio y hacé clic en **Run App**.

## Ejercicio propuesto
Agregá un segundo `reactive()` que devuelva el departamento con mayor participación entre los filtrados y mostralo en un `textOutput()`. Después probá `options(shiny.reactlog = TRUE)` y `Ctrl+F3` para ver el grafo de reactividad.

---
Curso *Visualización interactiva de datos con R y Shiny* · Udelar.
