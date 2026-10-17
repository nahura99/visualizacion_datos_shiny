# =============================================================================
# SOLUCIÓN · EJERCICIO EXTRA 6 · Gráficos por capas
# =============================================================================

library(shiny)
library(bslib)
library(ggplot2)
library(plotly)

################################################################################
## ZONA DE PRUEBAS
TITULO <- "Plebiscitos 2024"

COLOR_PRINCIPAL <- "#5A189A"
COLOR_FONDO     <- "#FFFFFF"
COLOR_TEXTO     <- "#2E0A4E"

PALETA_REGIONES <- "Dark2"

################################################################################

tema <- bs_theme(version = 5, bg = COLOR_FONDO, fg = COLOR_TEXTO,
                 primary = COLOR_PRINCIPAL)

# CODIGO ESTATICO
elecciones <- read.csv("../datos/elecciones_departamento_2024.csv", encoding = "UTF-8")
regiones   <- sort(unique(elecciones$region))


################################################################################
# INTERFAZ (UI)

barra <- sidebarPanel(
  selectInput("region", "Región:",
              choices = regiones, selected = regiones, multiple = TRUE),

  # CONSIGNA 3
  selectInput("tema", "Aspecto de los gráficos:",
              choices = c("minimal", "classic", "bw"))
)

ui <- fluidPage(
  theme = tema,
  titlePanel(TITULO),
  sidebarLayout(
    barra,
    mainPanel(
      tabsetPanel(
        tabPanel("Art. 11", br(), plotOutput("barras", height = "500px")),

        # CONSIGNA 2
        tabPanel("Los dos plebiscitos", br(),
                 plotlyOutput("puntos", height = "500px"))
      )
    )
  )
)


################################################################################
# SERVIDOR (SERVER)

server <- function(input, output, session) {

  datos <- reactive({
    req(input$region)
    elecciones[elecciones$region %in% input$region, ]
  })

  # CONSIGNA 3. Del texto del menú a la función del tema.
  tema_grafico <- reactive({
    switch(input$tema,
           minimal = theme_minimal(base_size = 14),
           classic = theme_classic(base_size = 14),
           bw      = theme_bw(base_size = 14))
  })

  # CONSIGNA 1. geom_col() dibuja las barras, reorder() las ordena y labs()
  # pone los títulos. Y el tema sale del reactive de arriba.
  output$barras <- renderPlot({
    ggplot(datos(), aes(x = pct_si_art11, y = reorder(departamento, pct_si_art11))) +
      geom_col(fill = COLOR_PRINCIPAL) +
      labs(x = "SÍ al Art. 11 (%)", y = NULL) +
      tema_grafico()
  })

  # CONSIGNA 2. text = departamento y tooltip = "text" para que el mouse
  # muestre solo el nombre.
  output$puntos <- renderPlotly({
    g <- ggplot(datos(), aes(x = pct_si_art11, y = pct_si_art67,
                             colour = region, text = departamento)) +
      geom_point(size = 3) +
      scale_colour_brewer(palette = PALETA_REGIONES) +
      labs(x = "SÍ al Art. 11 (%)", y = "SÍ al Art. 67 (%)", colour = "Región") +
      tema_grafico()
    ggplotly(g, tooltip = "text")
  })
}


################################################################################
shinyApp(ui = ui, server = server)
