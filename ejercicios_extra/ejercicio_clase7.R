# =============================================================================
# EJERCICIO EXTRA 7 · Un tablero por departamento
# Una app con barra de navegación que muestra un departamento por vez. Falta
# una caja de números, falta el mapa de locales y hay que darle tema propio.
# =============================================================================

# Para después de la Clase 7. Es el más largo, tomalo con calma.
# Fijate que acá el menú elige UN solo departamento (no varios), y que la
# app mezcla tres tablas, elecciones, locales y censo.
# Los datos se leen de ../datos/ como en las clases 2 a 6. Si después la
# querés publicar, acordate de lo que vimos con la carpeta datos/ propia.

library(shiny)
library(bslib)
library(DT)
library(leaflet)

################################################################################
## ZONA DE PRUEBAS
TITULO <- "Mi departamento en 2024"

COLOR_PRINCIPAL <- "#5A189A"
COLOR_FONDO     <- "#FFFFFF"
COLOR_TEXTO     <- "#2E0A4E"

# CONSIGNA 4
# Sumá un color para la barra de navegación y usalo en el tema (más abajo).
# Elegí también otra tipografía de Google Fonts para los títulos.

################################################################################

tema <- bs_theme(version = 5, bg = COLOR_FONDO, fg = COLOR_TEXTO,
                 primary = COLOR_PRINCIPAL)

# CODIGO ESTATICO
elecciones <- read.csv("../datos/elecciones_departamento_2024.csv", encoding = "UTF-8")
locales    <- read.csv("../datos/elecciones_locales_2024.csv",      encoding = "UTF-8")
censo      <- read.csv("../datos/censo_departamentos.csv",          encoding = "UTF-8")

# Solo locales con coordenadas
locales <- locales[!is.na(locales$Latitud), ]

departamentos <- sort(elecciones$departamento)

# Para el mapa (consigna 2)
COLORES_LEMAS <- c("Frente Amplio"    = "#1F4FA3",
                   "Partido Nacional" = "#7FB3E8",
                   "Partido Colorado" = "#D94F3D")


################################################################################
# INTERFAZ (UI)

barra <- sidebar(
  title = "Filtro",
  selectInput("depto", "Departamento:", choices = departamentos, selected = "Florida"),
  p("Fuente: Corte Electoral e INE")
)

# CONSIGNA 1
# Hay dos cajas. Sumá una tercera con la población de 2023 del departamento
# (sale de la tabla censo). Ponele un ícono, por ejemplo icon("people-group").
# Ojo que el output todavía no existe, también lo tenés que escribir en el
# server.
numeros <- layout_columns(
  value_box("Habilitados", textOutput("habilitados"),
            showcase = icon("users"), theme = "primary"),
  value_box("Lema ganador", textOutput("ganador"),
            showcase = icon("check"), theme = "primary")
)

ui <- page_navbar(
  title   = TITULO,
  theme   = tema,
  sidebar = barra,
  fillable = FALSE,

  nav_panel("Resumen", numeros),

  nav_panel("Locales",
            card(card_header("Locales de votación"),
                 DTOutput("t_locales", fill = FALSE)))

  # CONSIGNA 2
  # Sumá un nav_panel "Mapa" con una card y un leafletOutput("mapa") adentro.
)


################################################################################
# SERVIDOR (SERVER)

server <- function(input, output, session) {

  # Las filas del departamento elegido, en cada una de las tres tablas
  depto_elec <- reactive({
    elecciones[elecciones$departamento == input$depto, ]
  })

  depto_locales <- reactive({
    locales[locales$DepartamentoNombre == input$depto, ]
  })

  # depto_censo ... (lo vas a necesitar para la consigna 1)

  output$habilitados <- renderText({
    format(depto_elec()$habilitados, big.mark = ".", decimal.mark = ",")
  })

  output$ganador <- renderText({
    depto_elec()$lema_ganador
  })

  # CONSIGNA 3
  # La tabla muestra 10 filas por página y los textos en inglés. Hacé que
  # muestre 5 filas y que esté en español (la clase tiene cómo).
  # Y ya que estás, sacale la columna de números de fila.
  output$t_locales <- renderDT({
    l <- depto_locales()[, c("Localidad", "NombreLocal", "TotalHabilitados", "LemaGanador")]
    datatable(l)
  })

  # CONSIGNA 2 (sigue)
  # Escribí output$mapa con renderLeaflet(). Un punto por local, en
  # Longitud y Latitud, con el color del lema que ganó en ese local
  # (columna LemaGanador). Para los colores usá colorFactor() con
  # COLORES_LEMAS, y agregá la leyenda.
  # Que al pasar el mouse por un punto se vea el nombre del local.
}


################################################################################
shinyApp(ui = ui, server = server)
