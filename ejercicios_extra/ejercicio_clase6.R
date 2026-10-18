# =============================================================================
# EJERCICIO EXTRA 6 · Gráficos por capas
# Un tablero de los plebiscitos con un ggplot sin terminar. Hay que
# completarlo, sumar un gráfico interactivo y dejar elegir el tema.
# =============================================================================

################################################################################
## PASO 0 · LA RUTA A LOS DATOS
# La app lee las tablas de la carpeta datos/. Antes de empezar, revisá que la
# ruta de abajo lleve a esa carpeta.
#
# Run App trabaja desde la carpeta donde está guardado ESTE archivo.
#   - Si está en ejercicios_extra/, dentro de la carpeta del curso, datos/
#     queda un nivel más arriba. Por eso la ruta empieza con "../"
#   - Si lo guardaste en otro lado, poné la ruta a tu carpeta datos, con
#     barras / y una barra al final. Por ejemplo
#     "C:/Users/tu_usuario/Documents/curso_shiny/datos/"
# Si la ruta está mal, al apretar Run App aparece un error que dice
# "cannot open file" o "No such file or directory".
RUTA_DATOS <- "../datos/"

# Para después de la Clase 6.
# Los datos filtrados ya están en datos(), así que acá se trabaja solo
# con los gráficos.

library(shiny)
library(bslib)
library(ggplot2)
library(plotly)

################################################################################
## ZONA DE PRUEBAS
TITULO <- "Plebiscitos 2024"

COLOR_PRINCIPAL <- "#5A189A"
COLOR_FONDO     <- "#FFFFFF"
COLOR_TEXTO     <- "#2E0A4E"

PALETA_REGIONES <- "Dark2"

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

  # CONSIGNA 3
  # Agregá un menú para elegir el aspecto de los gráficos, con tres opciones,
  # "minimal", "classic" y "bw".
)

ui <- fluidPage(
  theme = tema,
  titlePanel(TITULO),
  sidebarLayout(
    barra,
    mainPanel(
      tabsetPanel(
        tabPanel("Art. 11", br(), plotOutput("barras", height = "500px"))

        # CONSIGNA 2. La pestaña nueva va acá.
      )
    )
  )
)


################################################################################
# SERVIDOR (SERVER)

server <- function(input, output, session) {

  datos <- reactive({
    req(input$region)
    elecciones[elecciones$region %in% input$region, ]
  })

  # CONSIGNA 1
  # Este ggplot está a medio hacer, cuando corrés la app salen los nombres
  # de los departamentos pero ninguna barra. Le falta la capa que las dibuja. Agregala con el color
  # COLOR_PRINCIPAL, y después
  #   - ordená los departamentos de mayor a menor (reorder)
  #   - poné títulos a los ejes con labs()
  output$barras <- renderPlot({
    ggplot(datos(), aes(x = pct_si_art11, y = departamento)) +
      theme_minimal(base_size = 14)
  })

  # CONSIGNA 2
  # Sumá una pestaña "Los dos plebiscitos" con un gráfico de puntos.
  #   eje x   pct_si_art11
  #   eje y   pct_si_art67
  #   color   region (con scale_colour_brewer y PALETA_REGIONES)
  # Tiene que ser interactivo, que al pasar el mouse por un punto diga el
  # nombre del departamento. Mirá cómo se hizo la dispersión en la clase,
  # es casi igual (plotlyOutput, renderPlotly, ggplotly).

  # CONSIGNA 3 (sigue)
  # Con lo que elijan en el menú, los dos gráficos tienen que cambiar de tema.
  # Pista, con switch() se puede pasar del texto ("bw") a la función
  # (theme_bw()). Lo usamos en la Clase 2 para el LAYOUT.
  # Conviene armarlo una vez, en un reactive, y sumarlo en los dos ggplot.
}


################################################################################
shinyApp(ui = ui, server = server)
