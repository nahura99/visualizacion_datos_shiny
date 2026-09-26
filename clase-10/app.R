# =============================================================================
# CLASE 10 — Trabajo Final (II): terminar, escalar y presentar
# Curso: Visualización interactiva de datos con R y Shiny (Udelar)
# -----------------------------------------------------------------------------
# Objetivo de la clase:
#   - Dar el toque final a la Shiny: estética, orden del código y despliegue.
#   - Aprender a ESCALAR una app compleja con MÓDULOS de Shiny, que evitan
#     repetir código cuando hay varias secciones parecidas.
#
# Esta app de referencia arma TRES secciones idénticas en estructura (una por
# variable) reutilizando un mismo módulo. Es el patrón para apps grandes.
# Al final: ver checklist de cierre y rúbrica en el README de la clase.
# =============================================================================

library(shiny)
library(bslib)
library(ggplot2)

ruta <- if (file.exists("datos/elecciones_departamento_2024.csv"))
  "datos/elecciones_departamento_2024.csv" else "../datos/elecciones_departamento_2024.csv"
elecciones <- read.csv(ruta, encoding = "UTF-8")

morado <- "#5A189A"; morado_profundo <- "#2E0A4E"
tema <- bs_theme(version = 5, bg = "#FFFFFF", fg = morado_profundo,
                 primary = morado, base_font = font_google("Inter"),
                 heading_font = font_google("Oswald"))

# --- MÓDULO: un panel reutilizable (UI + server) ----------------------------
# Un módulo es un par de funciones que encapsulan una parte de la app.
# Reciben un "id" que aísla sus inputs/outputs del resto.

panelUI <- function(id, titulo) {
  ns <- NS(id)                 # ns() genera ids únicos para este módulo
  card(
    card_header(titulo),
    selectInput(ns("region"), "Región:",
                choices = sort(unique(elecciones$region)),
                selected = sort(unique(elecciones$region)), multiple = TRUE),
    plotOutput(ns("grafico"))
  )
}

panelServer <- function(id, variable, etiqueta) {
  moduleServer(id, function(input, output, session) {
    output$grafico <- renderPlot({
      req(input$region)
      d <- elecciones[elecciones$region %in% input$region, ]
      ggplot(d, aes(x = reorder(departamento, .data[[variable]]),
                    y = .data[[variable]])) +
        geom_col(fill = morado) +
        coord_flip() +
        labs(x = NULL, y = etiqueta) +
        theme_minimal(base_size = 13)
    })
  })
}

# --- APP: reutilizamos el módulo tres veces ---------------------------------
ui <- page_navbar(
  title = "App con módulos (referencia)", theme = tema,
  nav_panel("Participación", panelUI("part", "Participación (%) por departamento")),
  nav_panel("Margen",        panelUI("mar",  "Margen del ganador (pp)")),
  nav_panel("Habilitados",   panelUI("hab",  "Personas habilitadas"))
)

server <- function(input, output, session) {
  panelServer("part", "participacion_pct", "Participación (%)")
  panelServer("mar",  "margen_pct",        "Margen del ganador (pp)")
  panelServer("hab",  "habilitados",       "Personas habilitadas")
}

shinyApp(ui, server)
