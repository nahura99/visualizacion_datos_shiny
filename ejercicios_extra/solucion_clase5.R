# =============================================================================
# SOLUCIÓN · EJERCICIO EXTRA 5 · Calcular una sola vez
# =============================================================================

## PASO 0 · Ruta a los datos
# "../datos/" si este archivo está en ejercicios_extra/ del curso. Si no, la
# ruta a tu carpeta datos, con barras / y una barra al final.
RUTA_DATOS <- "../datos/"

library(shiny)
library(bslib)

###############################################################################

TITULO <- "Participación electoral 2024"
COLOR_PRINCIPAL <- "#5A189A"
tema <- bs_theme(version = 5, bg = "#FFFFFF", fg = "#2E0A4E", primary = COLOR_PRINCIPAL)

elecciones <- read.csv(paste0(RUTA_DATOS, "elecciones_departamento_2024.csv"), encoding = "UTF-8")
regiones   <- sort(unique(elecciones$region))

###############################################################################

barra <- sidebarPanel(
  selectInput("region", "Región:", choices = regiones, selected = regiones, multiple = TRUE),
  sliderInput("blanco", "Voto en blanco máximo (%):", min = 1, max = 2, value = 2, step = 0.1),
  actionButton("actualizar", "Actualizar", class = "btn-primary")   # Consigna 3
)

ui <- fluidPage(theme = tema, titlePanel(TITULO), sidebarLayout(barra, mainPanel(
  h4(textOutput("n_deptos")),
  plotOutput("grafico", height = "450px"),
  tableOutput("tabla")
)))

###############################################################################

server <- function(input, output, session) {
  # Consignas 1 a 3. El filtro una sola vez; req() espera si no hay datos;
  # eventReactive() recalcula solo con el botón (y una vez al arrancar).
  datos <- eventReactive(input$actualizar, {
    req(input$region)
    d <- elecciones[elecciones$region %in% input$region & elecciones$en_blanco_pct <= input$blanco, ]
    req(nrow(d) > 0)
    d
  }, ignoreNULL = FALSE)

  output$n_deptos <- renderText({
    paste(nrow(datos()), "departamentos")
  })
  output$grafico <- renderPlot({
    d <- datos()
    d <- d[order(d$participacion_pct), ]
    par(mar = c(4, 9, 2, 1))
    barplot(d$participacion_pct, names.arg = d$departamento, horiz = TRUE, las = 1,
            col = COLOR_PRINCIPAL, border = NA, cex.names = 0.8,
            xlim = c(0, 100), main = "Participación (%)")
  })
  output$tabla <- renderTable({
    d <- datos()
    d[order(-d$participacion_pct),
      c("departamento", "region", "participacion_pct", "en_blanco_pct", "anulados_pct")]
  })
}

###############################################################################

shinyApp(ui, server)
