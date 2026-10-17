# =============================================================================
# EJERCICIO EXTRA 2 · Un menú para el censo
# Un menú elige un departamento y una ficha cuenta cuánta gente vive ahí. El
# menú está incompleto y la ficha dice poco.
# =============================================================================

# Para después de la Clase 2.
# Corré la app tal como está. Funciona, pero el menú tiene un solo
# departamento y la ficha está a medio escribir.

library(shiny)
library(bslib)

################################################################################
## ZONA DE PRUEBAS
TITULO <- "El censo por departamento"

COLOR_PRINCIPAL <- "#5A189A"
COLOR_FONDO     <- "#FFFFFF"
COLOR_TEXTO     <- "#2E0A4E"

# Disposición "simple", "lateral", "columnas"
# CONSIGNA 3 (la más fácil, se puede hacer primero)
# Probá las tres. Quedate con la que te parezca que se lee mejor.
LAYOUT <- "simple"

################################################################################

tema <- bs_theme(version = 5, bg = COLOR_FONDO, fg = COLOR_TEXTO,
                 primary = COLOR_PRINCIPAL)

# CODIGO ESTATICO
censo <- read.csv("../datos/censo_departamentos.csv", encoding = "UTF-8")

# CONSIGNA 1
# Este vector es el que usa el menú, y ahora tiene un solo departamento.
# Cambialo para que tenga los 19, ordenados alfabéticamente.
# Pista, en la app de la Clase 2 está casi igual.
departamentos <- c("Montevideo")


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

  # CONSIGNA 2
  # La ficha solo dice la población de 2023. Completala para que también diga
  # cuánto cambió la población desde 2011 (columna variacion_pct).
  # Algo así, "En Maldonado viven 212.951 personas. Desde 2011 la población
  # cambió un 29.6%."
  output$ficha <- renderText({
    fila <- censo[censo$departamento == input$depto, ]
    paste0(
      "En ", fila$departamento, " viven ",
      format(fila$poblacion_2023, big.mark = ".", decimal.mark = ","), " personas."
    )
  })

  # Esta tabla no depende del menú, queda siempre igual
  output$tabla <- renderTable({
    censo[order(-censo$poblacion_2023),
          c("departamento", "region", "poblacion_2023", "variacion_pct")]
  })
}


################################################################################
shinyApp(ui = ui, server = server)

# Extra (opcional). Ordená la tabla por densidad (densidad_2023) en lugar de
# por población. Qué departamento queda primero?
