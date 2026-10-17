# =============================================================================
# SOLUCIÓN · EJERCICIO EXTRA 4 · Más controles
# =============================================================================

library(shiny)
library(bslib)

################################################################################
## ZONA DE PRUEBAS
TITULO <- "Voto por departamento"

COLOR_PRINCIPAL <- "#5A189A"
COLOR_FONDO     <- "#FFFFFF"
COLOR_TEXTO     <- "#2E0A4E"

################################################################################

tema <- bs_theme(version = 5, bg = COLOR_FONDO, fg = COLOR_TEXTO,
                 primary = COLOR_PRINCIPAL)

# CODIGO ESTATICO
elecciones <- read.csv("../datos/elecciones_departamento_2024.csv", encoding = "UTF-8")
regiones   <- sort(unique(elecciones$region))

partidos <- c("Frente Amplio"    = "pct_frente_amplio",
              "Partido Nacional" = "pct_partido_nacional",
              "Partido Colorado" = "pct_partido_colorado")


################################################################################
# INTERFAZ (UI)

barra <- sidebarPanel(
  selectInput("region", "Región:",
              choices = regiones, selected = regiones, multiple = TRUE),

  # CONSIGNA 1
  textInput("titulo", "Título del gráfico:", value = "Votos por departamento (%)"),

  # CONSIGNA 2
  sliderInput("margen", "Margen mínimo (puntos):", min = 0, max = 35, value = 0),

  # CONSIGNA 3
  selectInput("partido", "Partido:", choices = partidos)
)

ui <- fluidPage(
  theme = tema,
  titlePanel(TITULO),
  sidebarLayout(
    barra,
    mainPanel(
      tabsetPanel(
        tabPanel("Gráfico", br(), plotOutput("grafico", height = "500px")),
        tabPanel("Tabla",   br(), tableOutput("tabla")),
        # Opcional
        tabPanel("Qué devuelve cada input", br(), verbatimTextOutput("consola"))
      )
    )
  )
)


################################################################################
# SERVIDOR (SERVER)

server <- function(input, output, session) {

  output$grafico <- renderPlot({
    # CONSIGNA 2. Se suma la condición del margen con &.
    d <- elecciones[elecciones$region %in% input$region &
                    elecciones$margen_pct >= input$margen, ]
    req(nrow(d) > 0)
    # CONSIGNA 3. d[[input$partido]] en lugar de d$pct_frente_amplio.
    d <- d[order(d[[input$partido]]), ]
    par(mar = c(4, 9, 3, 1))
    barplot(d[[input$partido]], names.arg = d$departamento, horiz = TRUE, las = 1,
            col = COLOR_PRINCIPAL, border = NA, cex.names = 0.8,
            main = input$titulo)   # CONSIGNA 1
  })

  output$tabla <- renderTable({
    d <- elecciones[elecciones$region %in% input$region &
                    elecciones$margen_pct >= input$margen, ]
    d[order(-d[[input$partido]]),
      c("departamento", "region", "lema_ganador", "margen_pct", input$partido)]
  })

  output$consola <- renderPrint({
    list(region = input$region, titulo = input$titulo,
         margen = input$margen, partido = input$partido)
  })
}


################################################################################
shinyApp(ui = ui, server = server)
