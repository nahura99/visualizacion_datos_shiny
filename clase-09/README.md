# Clase 9 · Puesta en Producción: la app final

## Objetivo
Integrar todo lo aprendido en una app compleja de tres paneles, depurar los errores más comunes y publicarla en shinyapps.io.

## Qué hace la app
Un tablero completo sobre la Elección Nacional 2024 con un filtro global de departamento y tres paneles.

**Gráficos** (ggplot2 y plotly)
1. Ranking por departamento, con variable a elección.
2. Dispersión interactiva entre dos variables (plotly).
3. Composición del voto por lema (barras apiladas).
4. Plebiscitos, SÍ al Art. 11 vs. SÍ al Art. 67 (gráfico de pesas).

**Tablas** (DT)
1. Resultados por departamento con filtros por columna y exportación.
2. Resumen por región (agregación con `aggregate()`).
3. Ranking de locales de votación, mayor y menor valor de la variable elegida.
4. Todos los locales con filtros por columna y descarga.

**Mapas** (leaflet, a nivel de local de votación o de circuito)
1. Lema ganador.
2. Porcentaje de un lema a elección.
3. Resultado de un plebiscito a elección.
4. Un indicador a elección (participación, voto en blanco, anulado, observado, margen).

Los mapas 2 a 4 admiten una escala relativa al promedio nacional.

## Componentes nuevos que se explican en clase
| Componente | Para qué sirve |
|---|---|
| `leaflet()`, `addProviderTiles()`, `setView()` | Mapa base. |
| `addCircleMarkers()`, `addLegend()` | Puntos con color, tamaño, etiqueta y popup. |
| `leafletProxy()` | Repintar los puntos sin redibujar el mapa entero. |
| `colorNumeric()` | Escala continua de color. |
| `tryCatch()` y `stopifnot()` al leer datos | Fallar temprano y con mensaje claro. |
| `validate(need())` en cada reactive | Ningún filtro rompe la app. |
| `options(shiny.sanitize.errors)` | Ocultar el detalle de los errores al publicar. |
| Una función `pintar_mapa()` | Los cuatro mapas comparten el mismo código. |
| `rsconnect::deployApp()` | Publicar (ver `deploy.R` y `../GUIA-DEPLOY.md`). |

## Depuración: los errores más comunes
| Síntoma | Causa habitual | Solución |
|---|---|---|
| `cannot open file 'datos/...'` | La app no encuentra el CSV. | Los datos viajan con la app. Copialos a `datos/` dentro de la carpeta. |
| `there is no package called ...` | Falta un paquete. | `install.packages()` y declararlo con `library()`. |
| Pantalla gris al abrir en shinyapps.io | La app falló al arrancar. | `rsconnect::showLogs()`. |
| `argument is of length zero` | Un input todavía es `NULL`. | `req(input$x)`. |
| Un filtro deja la tabla vacía y todo se rompe | Falta validar. | `validate(need(nrow(d) > 0, "mensaje"))`. |
| El mapa no aparece en una pestaña | Se dibujó oculto. | Crear el mapa vacío con `renderLeaflet()` y pintar con `leafletProxy()`. |

## Cómo correr la app
Abrí `app.R` en RStudio y hacé clic en **Run App**. Necesitás `shiny`, `bslib`, `ggplot2`, `plotly`, `DT`, `leaflet` y `scales`. La carpeta `datos/` de esta clase tiene su propia copia de los tres CSV para que el deploy funcione.

## Ejercicio propuesto
Publicá tu propia versión de la app en shinyapps.io y compartí la URL. Antes, cambiá `options(shiny.sanitize.errors = TRUE)`.

---
Curso *Visualización interactiva de datos con R y Shiny* · Udelar.
