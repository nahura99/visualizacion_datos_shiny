# =============================================================================
# SOLUCIÓN · EJERCICIO EXTRA 4 · Más controles
# =============================================================================

## PASO 0 · Ruta a los datos
# "../datos/" si este archivo está en ejercicios_extra/ del curso. Si no, la
# ruta a tu carpeta datos, con barras / y una barra al final.
RUTA_DATOS <- "../datos/"

library(shiny)
library(bslib)

TITULO <- "Voto por departamento"
COLOR_PRINCIPAL <- "#5A189A"
tema <- bs_theme(version = 5, bg = "#FFFFFF", fg = "#2E0A4E", primary = COLOR_PRINCIPAL)

elecciones <- read.csv(paste0(RUTA_DATOS, "elecciones_departamento_2024.csv"), encoding = "UTF-8")
regiones   <- sort(unique(elecciones$region))
partidos   <- c("Frente Amplio"    = "pct_frente_amplio",
                "Partido Nacional" = "pct_partido_nacional",
                "Partido Colorado" = "pct_partido_colorado")

barra <- sidebarPanel(
  selectInput("region", "Región:", choices = regiones, selected = regiones, multiple = TRUE),
  textInput("titulo", "Título del gráfico:", value = "Votos por departamento (%)"),   # Consigna 1
  sliderInput("margen", "Margen mínimo (puntos):", min = 0, max = 35, value = 0),     # Consigna 2
  selectInput("partido", "Partido:", choices = partidos)                              # Consigna 3
)

ui <- fluidPage(theme = tema, titlePanel(TITULO), sidebarLayout(barra, mainPanel(
  tabsetPanel(
    tabPanel("Gráfico", br(), plotOutput("grafico", height = "500px")),
    tabPanel("Tabla",   br(), tableOutput("tabla")),
    tabPanel("Inputs",  br(), verbatimTextOutput("consola"))   # Opcional
  )
)))

server <- function(input, output, session) {
  # Consigna 2, la condición del margen se suma con & en los dos filtros
  output$grafico <- renderPlot({
    d <- elecciones[elecciones$region %in% input$region & elecciones$margen_pct >= input$margen, ]
    req(nrow(d) > 0)
    d <- d[order(d[[input$partido]]), ]   # Consigna 3, d[[input$partido]] elige la columna
    par(mar = c(4, 9, 3, 1))
    barplot(d[[input$partido]], names.arg = d$departamento, horiz = TRUE, las = 1,
            col = COLOR_PRINCIPAL, border = NA, cex.names = 0.8, main = input$titulo)
  })
  output$tabla <- renderTable({
    d <- elecciones[elecciones$region %in% input$region & elecciones$margen_pct >= input$margen, ]
    d[order(-d[[input$partido]]), c("departamento", "region", "lema_ganador", "margen_pct", input$partido)]
  })
  output$consola <- renderPrint({
    list(region = input$region, titulo = input$titulo,
         margen = input$margen, partido = input$partido)
  })
}

shinyApp(ui, server)
