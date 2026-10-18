# =============================================================================
# SOLUCIÓN · EJERCICIO EXTRA 6 · Gráficos por capas


###############################################################################
RUTA_DATOS <- "../datos/"

library(shiny)
library(bslib)
library(ggplot2)
library(plotly)

###############################################################################

TITULO <- "Plebiscitos 2024"
COLOR_PRINCIPAL <- "#5A189A"
tema <- bs_theme(version = 5, bg = "#FFFFFF", fg = "#2E0A4E", primary = COLOR_PRINCIPAL)

elecciones <- read.csv(paste0(RUTA_DATOS, "elecciones_departamento_2024.csv"), encoding = "UTF-8")
regiones   <- sort(unique(elecciones$region))

###############################################################################

barra <- sidebarPanel(
  selectInput("region", "Región:", choices = regiones, selected = regiones, multiple = TRUE),
  selectInput("tema", "Aspecto de los gráficos:", choices = c("minimal", "classic", "bw"))   # Consigna 3
)

ui <- fluidPage(theme = tema, titlePanel(TITULO), sidebarLayout(barra, mainPanel(
  tabsetPanel(
    tabPanel("Art. 11", br(), plotOutput("barras", height = "500px")),
    tabPanel("Los dos plebiscitos", br(), plotlyOutput("puntos", height = "500px"))   # Consigna 2
  )
)))

###############################################################################

server <- function(input, output, session) {
  datos <- reactive({
    req(input$region)
    elecciones[elecciones$region %in% input$region, ]
  })

  # Consigna 3, del texto del menú a la función del tema
  tema_grafico <- reactive({
    switch(input$tema,
           minimal = theme_minimal(base_size = 14),
           classic = theme_classic(base_size = 14),
           bw      = theme_bw(base_size = 14))
  })

  # Consigna 1, geom_col() dibuja las barras y reorder() las ordena
  output$barras <- renderPlot({
    ggplot(datos(), aes(x = pct_si_art11, y = reorder(departamento, pct_si_art11))) +
      geom_col(fill = COLOR_PRINCIPAL) +
      labs(x = "SÍ al Art. 11 (%)", y = NULL) +
      tema_grafico()
  })

  # Consigna 2, text = departamento es lo que muestra el mouse
  output$puntos <- renderPlotly({
    g <- ggplot(datos(), aes(x = pct_si_art11, y = pct_si_art67,
                             colour = region, text = departamento)) +
      geom_point(size = 3) +
      scale_colour_brewer(palette = "Dark2") +
      labs(x = "SÍ al Art. 11 (%)", y = "SÍ al Art. 67 (%)", colour = "Región") +
      tema_grafico()
    ggplotly(g, tooltip = "text")
  })
}

###############################################################################

shinyApp(ui, server)
