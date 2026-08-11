# =============================================================================
# CLASE 6 — Gráficos Dinámicos con ggplot2
# Curso: Visualización interactiva de datos con R y Shiny (Udelar)
# -----------------------------------------------------------------------------
# Objetivo de la clase:
#   - Integrar gráficos de ggplot2 que se actualizan según los filtros.
#   - Par output: plotOutput()  <->  renderPlot()
#   - Un gráfico de BARRAS (población por departamento) y uno de DISPERSIÓN
#     (población vs. superficie), ambos reactivos.
# =============================================================================

library(shiny)
library(ggplot2)

ruta <- if (file.exists("datos/censo_departamentos.csv")) {
  "datos/censo_departamentos.csv"
} else {
  "../datos/censo_departamentos.csv"
}
censo <- read.csv(ruta, encoding = "UTF-8")

regiones <- sort(unique(censo$region))

ui <- fluidPage(
  titlePanel("Clase 6 — Gráficos que reaccionan a los filtros"),

  sidebarLayout(
    sidebarPanel(
      selectInput("region", "Región:",
                  choices = regiones, selected = regiones, multiple = TRUE),
      radioButtons("variable", "Variable a graficar (barras):",
                   choices = c("Población 2023" = "poblacion_2023",
                               "Variación 2011-2023 (%)" = "variacion_pct",
                               "Densidad (hab/km²)" = "densidad_2023"),
                   selected = "poblacion_2023")
    ),

    mainPanel(
      tabsetPanel(
        tabPanel("Barras",
                 br(),
                 plotOutput("grafico_barras", height = "460px")),
        tabPanel("Dispersión",
                 br(),
                 p("Relación entre superficie y población de cada departamento."),
                 plotOutput("grafico_puntos", height = "460px"))
      )
    )
  )
)

server <- function(input, output, session) {

  datos_filtrados <- reactive({
    req(input$region)
    censo[censo$region %in% input$region, ]
  })

  # Etiqueta legible para el eje segun la variable elegida.
  etiqueta <- reactive({
    switch(input$variable,
           poblacion_2023 = "Población (2023)",
           variacion_pct  = "Variación 2011-2023 (%)",
           densidad_2023  = "Densidad (hab/km²)")
  })

  # ----- Gráfico de barras -------------------------------------------------
  output$grafico_barras <- renderPlot({
    d <- datos_filtrados()
    ggplot(d, aes(x = reorder(departamento, .data[[input$variable]]),
                  y = .data[[input$variable]],
                  fill = region)) +
      geom_col() +
      coord_flip() +
      labs(x = NULL, y = etiqueta(), fill = "Región",
           title = paste(etiqueta(), "por departamento")) +
      theme_minimal(base_size = 14)
  })

  # ----- Gráfico de dispersión ---------------------------------------------
  output$grafico_puntos <- renderPlot({
    d <- datos_filtrados()
    ggplot(d, aes(x = superficie_km2, y = poblacion_2023, color = region)) +
      geom_point(size = 4, alpha = 0.85) +
      scale_y_continuous(labels = scales::comma) +
      labs(x = "Superficie (km²)", y = "Población (2023)", color = "Región",
           title = "Superficie vs. población") +
      theme_minimal(base_size = 14)
  })
}

shinyApp(ui = ui, server = server)
