# Clase 01 — Bases de RStudio y Shiny

## Objetivo
Entender la arquitectura mínima de una app Shiny y la diferencia entre código estático y reactivo.

## Conceptos que se ven
- Las tres piezas: `ui`, `server`, `shinyApp()`.
- Código estático (se corre una vez al arrancar) vs. reactivo (se recalcula al interactuar).
- Pares output/render: `tableOutput()`/`renderTable()`, `textOutput()`/`renderText()`.

## Cómo correr la app
Abrí `app.R` en RStudio y hacé clic en **Run App** (o ejecutá `shiny::runApp()` desde esta carpeta).

## Ejercicio propuesto
Agregá un tercer output que muestre el departamento más poblado.

---
Curso *Visualización interactiva de datos con R y Shiny* · Udelar.
