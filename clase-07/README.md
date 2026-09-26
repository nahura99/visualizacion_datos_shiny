# Clase 7 · Gráficos Dinámicos

## Objetivo
Integrar gráficos de ggplot2 que se actualizan en tiempo real según los filtros, interactuar con el gráfico y pasar a gráficos web con plotly.

## Qué hace la app
Cuatro pestañas de gráficos. Barras por departamento con variable a elección, dispersión con clic para identificar el punto, histograma de participación a nivel de local de votación (2.521 locales) y una versión interactiva con plotly. El gráfico de barras se puede descargar como PNG.

## Componentes que se explican en clase
| Componente | Para qué sirve |
|---|---|
| `plotOutput()` y `renderPlot()` | Gráfico estático. El argumento `res` mejora la nitidez. |
| `aes(.data[[input$variable]])` | Mapear una columna elegida por el usuario. |
| `reorder()` y `coord_flip()` | Barras horizontales ordenadas. |
| `scale_fill_manual()` | Paleta propia (la del curso, por región). |
| `plotOutput(click = "id")` y `nearPoints()` | El gráfico como input. |
| `plotlyOutput()`, `renderPlotly()` y `ggplotly()` | Zoom, hover y leyenda clicable con una línea. |
| `downloadHandler()` y `ggsave()` | Descargar el gráfico. |
| Un `reactive()` que devuelve el ggplot | Reusar el mismo gráfico en pantalla y en la descarga. |

## Cómo correr la app
Abrí `app.R` en RStudio y hacé clic en **Run App**. Necesitás `ggplot2` y `plotly`.

## Ejercicio propuesto
Agregá una quinta pestaña con un gráfico de líneas o de puntos que compare `pct_si_art11` y `pct_si_art67` por departamento. Después reemplazá `nearPoints()` por `brushedPoints()` y un `brush` para seleccionar varios puntos a la vez.

---
Curso *Visualización interactiva de datos con R y Shiny* · Udelar.
