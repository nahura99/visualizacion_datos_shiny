# =============================================================================
# SOLUCIÓN · EJERCICIO EXTRA 2 · Un menú para el censo
# =============================================================================

library(shiny)
library(bslib)

################################################################################
## ZONA DE PRUEBAS
TITULO <- "El censo por departamento"

COLOR_PRINCIPAL <- "#5A189A"
COLOR_FONDO     <- "#FFFFFF"
COLOR_TEXTO     <- "#2E0A4E"

# CONSIGNA 3. Cualquiera de las tres está bien, acá quedó la lateral.
LAYOUT <- "lateral"

################################################################################

tema <- bs_theme(version = 5, bg = COLOR_FONDO, fg = COLOR_TEXTO,
                 primary = COLOR_PRINCIPAL)

# CODIGO ESTATICO
censo <- read.csv("../datos/censo_departamentos.csv", encoding = "UTF-8")

# CONSIGNA 1. La columna entera, ordenada con sort().
departamentos <- sort(censo$departamento)


################################################################################
# INTERFAZ (UI)

controles <- selectInput(
  inputId  = "depto",
  label    = "Elegí un departamento:",
  choices  = departamentos,
  selected = "Montevideo"
)

resultados <- tagList(
  h3("Ficha del departamento"),
  textOutput("ficha"),

  h3("Todos los departamentos"),
  tableOutput("tabla")
)

cuerpo <- switch(
  LAYOUT,
  simple   = tagList(controles, resultados),
  lateral  = sidebarLayout(sidebarPanel(controles), mainPanel(resultados)),
  columnas = fluidRow(column(6, controles), column(6, resultados))
)

ui <- fluidPage(
  theme = tema,
  titlePanel(TITULO),
  p("Datos de los Censos 2011 y 2023 (INE)."),
  cuerpo
)


################################################################################
# SERVIDOR (SERVER)

server <- function(input, output, session) {

  # CONSIGNA 2. Se agregan más pedazos al paste0(), separados por comas.
  # En Montevideo y Treinta y Tres da negativo, porque ahí la población bajó.
  output$ficha <- renderText({
    fila <- censo[censo$departamento == input$depto, ]
    paste0(
      "En ", fila$departamento, " viven ",
      format(fila$poblacion_2023, big.mark = ".", decimal.mark = ","), " personas. ",
      "Desde 2011 la población cambió un ", fila$variacion_pct, "%."
    )
  })

  # Extra. Se ordena por densidad_2023 (Montevideo queda primero, lejos).
  output$tabla <- renderTable({
    censo[order(-censo$densidad_2023),
          c("departamento", "region", "poblacion_2023", "variacion_pct", "densidad_2023")]
  })
}


################################################################################
shinyApp(ui = ui, server = server)
