# =============================================================================
# CLASE 7 — Estética y Navegación
# Curso: Visualización interactiva de datos con R y Shiny (Udelar)
# -----------------------------------------------------------------------------
# Objetivo de la clase:
#   - Mejorar el aspecto visual con {bslib} (temas de Bootstrap 5).
#   - Aplicar la ESTÉTICA del curso: paleta violeta profundo ("aesthetics").
#   - Organizar la navegación con page_navbar() y varias pestañas (nav_panel).
#   - Usar cards y value_box() para presentar la información con jerarquía.
# =============================================================================

library(shiny)
library(bslib)
library(ggplot2)

ruta <- if (file.exists("datos/censo_departamentos.csv")) {
  "datos/censo_departamentos.csv"
} else {
  "../datos/censo_departamentos.csv"
}
censo <- read.csv(ruta, encoding = "UTF-8")
regiones <- sort(unique(censo$region))

# --- ESTÉTICA DEL CURSO ("aesthetics") --------------------------------------
# Paleta violeta profundo inspirada en la identidad visual del curso.
morado_profundo <- "#2E0A4E"
morado          <- "#5A189A"
morado_claro    <- "#9D4EDD"
acento          <- "#C77DFF"

tema <- bs_theme(
  version      = 5,
  bg           = "#FFFFFF",
  fg           = morado_profundo,
  primary      = morado,
  secondary    = morado_claro,
  base_font    = font_google("Inter"),
  heading_font = font_google("Oswald")
)

ui <- page_navbar(
  title = "Censo 2023 · Uruguay",
  theme = tema,
  fillable = TRUE,

  sidebar = sidebar(
    title = "Filtros",
    selectInput("region", "Región:",
                choices = regiones, selected = regiones, multiple = TRUE),
    radioButtons("variable", "Variable (barras):",
                 choices = c("Población 2023" = "poblacion_2023",
                             "Variación (%)"   = "variacion_pct",
                             "Densidad"        = "densidad_2023"),
                 selected = "poblacion_2023")
  ),

  # ----- Pestaña 1: Resumen --------------------------------------------------
  nav_panel(
    title = "Resumen",
    layout_columns(
      fill = FALSE,
      value_box("Departamentos", textOutput("vb_deptos"),
                theme = value_box_theme(bg = morado, fg = "white")),
      value_box("Población 2023", textOutput("vb_pob"),
                theme = value_box_theme(bg = morado_claro, fg = "white")),
      value_box("Variación media", textOutput("vb_var"),
                theme = value_box_theme(bg = morado_profundo, fg = "white"))
    ),
    card(
      card_header("Población por departamento"),
      plotOutput("grafico")
    )
  ),

  # ----- Pestaña 2: Tabla ----------------------------------------------------
  nav_panel(
    title = "Tabla",
    card(
      card_header("Detalle por departamento"),
      tableOutput("tabla")
    )
  ),

  # ----- Pestaña 3: Acerca de ------------------------------------------------
  nav_panel(
    title = "Acerca de",
    card(
      card_header("Sobre este tablero"),
      p("Tablero de ejemplo del curso ", tags$em("Visualización interactiva",
        "de datos con R y Shiny"), " (Udelar)."),
      p(tags$strong("Datos:"), "Censo 2023, Instituto Nacional de Estadística (INE)."),
      p(tags$strong("Estética:"), "paleta violeta del curso.")
    )
  )
)

server <- function(input, output, session) {

  datos_filtrados <- reactive({
    req(input$region)
    censo[censo$region %in% input$region, ]
  })

  output$vb_deptos <- renderText(nrow(datos_filtrados()))
  output$vb_pob    <- renderText(format(sum(datos_filtrados()$poblacion_2023),
                                        big.mark = "."))
  output$vb_var    <- renderText(paste0(
    round(mean(datos_filtrados()$variacion_pct), 1), "%"))

  output$grafico <- renderPlot({
    d <- datos_filtrados()
    etiqueta <- switch(input$variable,
                       poblacion_2023 = "Población (2023)",
                       variacion_pct  = "Variación (%)",
                       densidad_2023  = "Densidad (hab/km²)")
    ggplot(d, aes(x = reorder(departamento, .data[[input$variable]]),
                  y = .data[[input$variable]])) +
      geom_col(fill = morado) +
      coord_flip() +
      labs(x = NULL, y = etiqueta) +
      theme_minimal(base_size = 14)
  })

  output$tabla <- renderTable({
    d <- datos_filtrados()
    d[order(-d$poblacion_2023), ]
  })
}

shinyApp(ui = ui, server = server)
