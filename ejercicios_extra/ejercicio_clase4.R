# =============================================================================
# EJERCICIO EXTRA 4 
#Mas controles, sumar grafico del voto al Frente Amplio que se filtra por region. Hay que
# sumar tres controles nuevos y conectarlos con el gráfico y la tabla.
# =============================================================================

################################################################################
#RUTA A LOS DATOS
# La app lee las tablas de la carpeta datos/. Antes de empezar, revisá que la
# ruta de abajo lleve a esa carpeta.
#
#   - Si está en ejercicios_extra/, dentro de la carpeta del curso, datos/
#     queda un nivel más arriba. Por eso la ruta empieza con "../"
#   - Si lo guardaste en otro lado, poné la ruta a tu carpeta datos, con
#     barras / y una barra al final. Por ejemplo
#     "C:/Users/tu_usuario/Documents/curso_shiny/datos/"
# Si la ruta está mal, al apretar Run App aparece un error
RUTA_DATOS <- "../datos/"

# RECORDAR! Cada control nuevo tiene dos partes, el input en la barra (UI) y el lugar
# del server donde se usa con input$id. 

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
# paste0() pega la ruta del PASO 0 con el nombre del archivo.
elecciones <- read.csv(paste0(RUTA_DATOS, "elecciones_departamento_2024.csv"), encoding = "UTF-8")
regiones   <- sort(unique(elecciones$region))


################################################################################
# INTERFAZ (UI)

barra <- sidebarPanel(
  selectInput("region", "Región:",
              choices = regiones, selected = regiones, multiple = TRUE)

  # CONSIGNA 1
  # Agregá un textInput() para escribir el título del gráfico. Que arranque
  # con un título ya escrito (argumento value).

  # CONSIGNA 2
  # Agregá un sliderInput() con el margen mínimo de victoria, de 0 a 35 puntos.
  # El margen está en la columna margen_pct (diferencia entre el primero y el
  # segundo).

  # CONSIGNA 3
  # Agregá un selectInput() para elegir el partido que muestra el gráfico.
  # Las opciones pueden ser este vector. Lo de la izquierda es lo que se ve en
  # el menú y lo de la derecha lo que recibe el server.
  #   c("Frente Amplio"    = "pct_frente_amplio",
  #     "Partido Nacional" = "pct_partido_nacional",
  #     "Partido Colorado" = "pct_partido_colorado")
)

ui <- fluidPage(
  theme = tema,
  titlePanel(TITULO),
  sidebarLayout(
    barra,
    mainPanel(
      tabsetPanel(
        tabPanel("Gráfico", br(), plotOutput("grafico", height = "500px")),
        tabPanel("Tabla",   br(), tableOutput("tabla"))
      )))
)


################################################################################
# SERVIDOR (SERVER)

server <- function(input, output, session) {

  # El filtro está dos veces, en el gráfico y en la tabla. Cuando sumes el
  # margen mínimo (consigna 2) lo vas a tener que cambiar en los dos lados.

  output$grafico <- renderPlot({
    d <- elecciones[elecciones$region %in% input$region, ]
    req(nrow(d) > 0)
    d <- d[order(d$pct_frente_amplio), ]
    par(mar = c(4, 9, 3, 1))
    barplot(d$pct_frente_amplio, names.arg = d$departamento, horiz = TRUE, las = 1,
            col = COLOR_PRINCIPAL, border = NA, cex.names = 0.8,
            main = "Votos al Frente Amplio (%)")   # <- consigna 1, acá va el título
  })

  # para la consigna 3. d[[input$partido]] devuelve la columna cuyo nombre
  # está guardado en input$partido. Lo vas a necesitar en dos lugares del
  # barplot (en el orden y en las barras).

  output$tabla <- renderTable({
    d <- elecciones[elecciones$region %in% input$region, ]
    d[order(-d$pct_frente_amplio),
      c("departamento", "region", "lema_ganador", "margen_pct", "pct_frente_amplio")]
  })
}


################################################################################
shinyApp(ui = ui, server = server)
