# =============================================================================
# EJERCICIO EXTRA 3 · Ordenar la pantalla
# Un tablero con barra lateral, números arriba y pestañas. Falta un número,
# falta una pestaña y la barra necesita un poco de texto.
# =============================================================================

# Para después de la Clase 3.
# La app ya filtra por región. Lo que hay que trabajar es la interfaz (UI),
# el server casi no se toca.

library(shiny)
library(bslib)

################################################################################
## ZONA DE PRUEBAS
TITULO <- "Elección Nacional 2024"

COLOR_PRINCIPAL <- "#5A189A"
COLOR_FONDO     <- "#FFFFFF"
COLOR_TEXTO     <- "#2E0A4E"

# "pills" o "tabs"
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
              choices = regiones, selected = regiones, multiple = TRUE)

  # CONSIGNA 3
  # Debajo del menú agregá
  #   - una línea divisoria
  #   - un subtítulo chico que diga "Fuente"
  #   - un párrafo con un link a la Corte Electoral, https://www.corteelectoral.gub.uy
  # Para el link se usa a(), con href = "la dirección". Fijate que sea clickeable.
)

# CONSIGNA 1
# Arriba van dos números en dos columnas de 6. En el server ya está calculado
# un tercero, output$votos_fa (votos al Frente Amplio), pero no se ve.
# Agregalo como una tercera columna y acomodá los anchos para que las tres
# entren en la misma fila (la pantalla tiene 12).
numeros <- fluidRow(
  column(6, h5("Departamentos"), h2(textOutput("n_deptos"), class = "text-primary")),
  column(6, h5("Emitidos"),      h2(textOutput("emitidos"), class = "text-primary"))
)

# CONSIGNA 2
# Hay una sola pestaña. Sumá una segunda pestaña, "Ayuda", que explique en
# dos o tres renglones qué es cada columna de la tabla. Usá p() y strong()
# para que el nombre de la columna quede en negrita.
pestanas <- tabsetPanel(
  type = ESTILO_PESTANAS,
  tabPanel("Tabla", br(), tableOutput("tabla"))
)

ui <- fluidPage(
  theme = tema,
  titlePanel(TITULO),
  sidebarLayout(
    barra,
    mainPanel(numeros, hr(), pestanas)
  )
)


################################################################################
# SERVIDOR (SERVER)

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

# Si querés seguir, pasá la barra a la derecha. Hay un argumento de
# sidebarLayout() que lo hace (lo vimos en clase).
