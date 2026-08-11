# =============================================================================
# CLASE 8 — Puesta en Producción (app integrada y completa)
# Curso: Visualización interactiva de datos con R y Shiny (Udelar)
# -----------------------------------------------------------------------------
# Objetivo de la clase:
#   - Integrar TODO lo aprendido en una Shiny "compleja" y prolija.
#   - Tabla interactiva con {DT}, descarga de datos, gráficos, value boxes.
#   - Manejo de errores (req/validate) y buenas prácticas para desplegar.
#   - Publicación en shinyapps.io (ver deploy.R y el README de la clase).
#
# Esta es la app hacia la que veníamos construyendo clase a clase.
# =============================================================================

library(shiny)
library(bslib)
library(ggplot2)
library(DT)

# --- Datos ------------------------------------------------------------------
ruta <- if (file.exists("datos/censo_departamentos.csv")) {
  "datos/censo_departamentos.csv"
} else {
  "../datos/censo_departamentos.csv"
}
censo <- read.csv(ruta, encoding = "UTF-8")
regiones <- sort(unique(censo$region))

# --- Estética del curso ("aesthetics") --------------------------------------
morado_profundo <- "#2E0A4E"
morado          <- "#5A189A"
morado_claro    <- "#9D4EDD"

tema <- bs_theme(
  version = 5, bg = "#FFFFFF", fg = morado_profundo,
  primary = morado, secondary = morado_claro,
  base_font = font_google("Inter"), heading_font = font_google("Oswald")
)

# --- UI ---------------------------------------------------------------------
ui <- page_navbar(
  title = "Tablero Censo 2023 · Uruguay",
  theme = tema,
  fillable = TRUE,

  sidebar = sidebar(
    title = "Filtros",
    selectInput("region", "Región:",
                choices = regiones, selected = regiones, multiple = TRUE),
    sliderInput("min_pob", "Población mínima (2023):",
                min = 0, max = max(censo$poblacion_2023),
                value = 0, step = 10000),
    radioButtons("variable", "Variable (barras):",
                 choices = c("Población 2023" = "poblacion_2023",
                             "Variación (%)"   = "variacion_pct",
                             "Densidad"        = "densidad_2023"),
                 selected = "poblacion_2023"),
    tags$hr(),
    downloadButton("descargar", "Descargar datos filtrados (.csv)",
                   class = "btn-primary")
  ),

  nav_panel(
    "Resumen",
    layout_columns(
      fill = FALSE,
      value_box("Departamentos", textOutput("vb_deptos"),
                theme = value_box_theme(bg = morado, fg = "white")),
      value_box("Población 2023", textOutput("vb_pob"),
                theme = value_box_theme(bg = morado_claro, fg = "white")),
      value_box("Variación media", textOutput("vb_var"),
                theme = value_box_theme(bg = morado_profundo, fg = "white"))
    ),
    layout_columns(
      card(card_header("Ranking por variable"), plotOutput("g_barras")),
      card(card_header("Superficie vs. población"), plotOutput("g_puntos"))
    )
  ),

  nav_panel(
    "Datos",
    card(
      card_header("Tabla interactiva (ordenar y buscar)"),
      DT::DTOutput("tabla")
    )
  ),

  nav_panel(
    "Acerca de",
    card(
      card_header("Sobre este tablero"),
      p("App final del bloque de clases 1-8 del curso ",
        tags$em("Visualización interactiva de datos con R y Shiny"), " (Udelar)."),
      p(tags$strong("Datos:"), "Censo 2023 — Instituto Nacional de Estadística (INE)."),
      p(tags$strong("Código:"), "una sola app; datos en la carpeta datos/."),
      p(tags$strong("Deploy:"), "shinyapps.io (ver deploy.R).")
    )
  )
)

# --- Server -----------------------------------------------------------------
server <- function(input, output, session) {

  datos_filtrados <- reactive({
    req(input$region)
    d <- censo[censo$region %in% input$region &
                 censo$poblacion_2023 >= input$min_pob, ]
    # validate() muestra un mensaje amable si el filtro no deja filas.
    validate(need(nrow(d) > 0, "No hay departamentos con estos filtros."))
    d
  })

  etiqueta <- reactive({
    switch(input$variable,
           poblacion_2023 = "Población (2023)",
           variacion_pct  = "Variación (%)",
           densidad_2023  = "Densidad (hab/km²)")
  })

  output$vb_deptos <- renderText(nrow(datos_filtrados()))
  output$vb_pob    <- renderText(format(sum(datos_filtrados()$poblacion_2023),
                                        big.mark = "."))
  output$vb_var    <- renderText(paste0(
    round(mean(datos_filtrados()$variacion_pct), 1), "%"))

  output$g_barras <- renderPlot({
    d <- datos_filtrados()
    ggplot(d, aes(x = reorder(departamento, .data[[input$variable]]),
                  y = .data[[input$variable]])) +
      geom_col(fill = morado) +
      coord_flip() +
      labs(x = NULL, y = etiqueta()) +
      theme_minimal(base_size = 13)
  })

  output$g_puntos <- renderPlot({
    d <- datos_filtrados()
    ggplot(d, aes(x = superficie_km2, y = poblacion_2023)) +
      geom_point(size = 4, color = morado_claro) +
      scale_y_continuous(labels = scales::comma) +
      labs(x = "Superficie (km²)", y = "Población (2023)") +
      theme_minimal(base_size = 13)
  })

  output$tabla <- DT::renderDT({
    DT::datatable(datos_filtrados(), options = list(pageLength = 10),
                  rownames = FALSE)
  })

  output$descargar <- downloadHandler(
    filename = function() "censo_filtrado.csv",
    content  = function(file) write.csv(datos_filtrados(), file, row.names = FALSE)
  )
}

shinyApp(ui = ui, server = server)
