# =============================================================================
# SOLUCIÓN · EJERCICIO EXTRA 1 · La primera app con otros datos
# =============================================================================

## PASO 0 · Ruta a los datos
# "../datos/" si este archivo está en ejercicios_extra/ del curso. Si no, la
# ruta a tu carpeta datos, con barras / y una barra al final.
RUTA_DATOS <- "../datos/"

library(shiny)

TITULO <- "Cuántos somos en cada departamento"   # Consigna 1, cualquier título

censo <- read.csv(paste0(RUTA_DATOS, "censo_departamentos.csv"), encoding = "UTF-8")

ui <- fluidPage(
  titlePanel(TITULO),
  p("Población de cada departamento según el Censo 2023 (INE)."),
  h3("Población por departamento"),
  tableOutput("tabla_censo"),
  textOutput("total"),   # Consigna 3, el output necesita su lugar en la UI
  p(em("Fuente: INE."))  # Extra
)

server <- function(input, output, session) {
  output$tabla_censo <- renderTable({
    censo[, c("departamento", "poblacion_2011", "poblacion_2023")]   # Consigna 2
  })
  output$total <- renderText({
    paste0("En 2023 Uruguay tenía ",
           format(sum(censo$poblacion_2023), big.mark = ".", decimal.mark = ","),
           " habitantes.")
  })
}

shinyApp(ui, server)
