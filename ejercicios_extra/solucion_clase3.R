# =============================================================================
# SOLUCIÓN · EJERCICIO EXTRA 3 · Ordenar la pantalla
# =============================================================================

library(shiny)
library(bslib)

################################################################################
## ZONA DE PRUEBAS
TITULO <- "Elección Nacional 2024"

COLOR_PRINCIPAL <- "#5A189A"
COLOR_FONDO     <- "#FFFFFF"
COLOR_TEXTO     <- "#2E0A4E"

ESTILO_PESTANAS <- "pills"

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
  hr(),
  h5("Fuente"),
  p("Corte Electoral, ",
    a("www.corteelectoral.gub.uy", href = "https://www.corteelectoral.gub.uy",
      target = "_blank"))   # target = "_blank" lo abre en otra pestaña
)

# CONSIGNA 1. Tres columnas de 4 (4 + 4 + 4 = 12).
numeros <- fluidRow(
  column(4, h5("Departamentos"),        h2(textOutput("n_deptos"), class = "text-primary")),
  column(4, h5("Emitidos"),             h2(textOutput("emitidos"), class = "text-primary")),
  column(4, h5("Votos al Frente Amplio"), h2(textOutput("votos_fa"), class = "text-primary"))
)

# CONSIGNA 2
pestanas <- tabsetPanel(
  type = ESTILO_PESTANAS,
  tabPanel("Tabla", br(), tableOutput("tabla")),
  tabPanel("Ayuda",
           br(),
           p(strong("emitidos"), "son los votos que se depositaron en las urnas."),
           p(strong("pct_frente_amplio"), "es el porcentaje del Frente Amplio sobre los votos a lemas."),
           p(strong("region"), "es la agrupación de departamentos que usamos en el curso."))
)

# Extra. position = "right" pasa la barra a la derecha.
ui <- fluidPage(
  theme = tema,
  titlePanel(TITULO),
  sidebarLayout(
    position = "right",
    barra,
    mainPanel(numeros, hr(), pestanas)
  )
)


################################################################################
# SERVIDOR (SERVER)
# Igual que en el ejercicio, no hacía falta tocarlo.

server <- function(input, output, session) {

  output$n_deptos <- renderText({
    d <- elecciones[elecciones$region %in% input$region, ]
    nrow(d)
  })

  output$emitidos <- renderText({
    d <- elecciones[elecciones$region %in% input$region, ]
    format(sum(d$emitidos), big.mark = ".", decimal.mark = ",")
  })

  output$votos_fa <- renderText({
    d <- elecciones[elecciones$region %in% input$region, ]
    format(sum(d$votos_frente_amplio), big.mark = ".", decimal.mark = ",")
  })

  output$tabla <- renderTable({
    d <- elecciones[elecciones$region %in% input$region, ]
    d[order(-d$emitidos), c("departamento", "region", "emitidos", "pct_frente_amplio")]
  })
}


################################################################################
shinyApp(ui = ui, server = server)
