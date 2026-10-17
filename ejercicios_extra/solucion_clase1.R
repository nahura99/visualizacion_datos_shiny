# =============================================================================
# SOLUCIÓN · EJERCICIO EXTRA 1 · La primera app con otros datos
# =============================================================================

library(shiny)

################################################################################
## ZONA DE PRUEBAS

# CONSIGNA 1. Cualquier título sirve.
TITULO <- "Cuántos somos en cada departamento"

################################################################################

# CODIGO ESTATICO
censo <- read.csv("../datos/censo_departamentos.csv", encoding = "UTF-8")


################################################################################
# INTERFAZ (UI)

ui <- fluidPage(

  titlePanel(TITULO),

  p("Población de cada departamento según el Censo 2023 (INE)."),

  h3("Población por departamento"),
  tableOutput("tabla_censo"),   # <- faltaba esta coma

  # CONSIGNA 3. No aparecía porque nadie le había hecho un lugar en la UI.
  # El id tiene que ser igual al del server, "total".
  textOutput("total")
)


################################################################################
# SERVIDOR (SERVER)

server <- function(input, output, session) {

  # CONSIGNA 2. Se suma "poblacion_2011" al vector de columnas.
  output$tabla_censo <- renderTable({
    censo[, c("departamento", "poblacion_2011", "poblacion_2023")]
  })

  output$total <- renderText({
    total <- sum(censo$poblacion_2023)
    paste0("En 2023 Uruguay tenía ",
           format(total, big.mark = ".", decimal.mark = ","), " habitantes.")
  })
}


################################################################################
# ARRANCAR LA APP
shinyApp(ui = ui, server = server)
