# =============================================================================
# SOLUCIÓN · EJERCICIO EXTRA 7 · Un tablero por departamento
# =============================================================================

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
COLOR_NAVEGACION <- "#2E0A4E"
FUENTE_TITULOS   <- "Oswald"

################################################################################

# CONSIGNA 4. "navbar-bg" pinta la barra y heading_font cambia los títulos.
tema <- bs_theme(version = 5, bg = COLOR_FONDO, fg = COLOR_TEXTO,
                 primary = COLOR_PRINCIPAL,
                 heading_font = font_google(FUENTE_TITULOS, local = FALSE),
                 "navbar-bg" = COLOR_NAVEGACION)

# CODIGO ESTATICO
elecciones <- read.csv("../datos/elecciones_departamento_2024.csv", encoding = "UTF-8")
locales    <- read.csv("../datos/elecciones_locales_2024.csv",      encoding = "UTF-8")
censo      <- read.csv("../datos/censo_departamentos.csv",          encoding = "UTF-8")

locales <- locales[!is.na(locales$Latitud), ]

departamentos <- sort(elecciones$departamento)

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
numeros <- layout_columns(
  value_box("Habilitados", textOutput("habilitados"),
            showcase = icon("users"), theme = "primary"),
  value_box("Lema ganador", textOutput("ganador"),
            showcase = icon("check"), theme = "primary"),
  value_box("Población 2023", textOutput("poblacion"),
            showcase = icon("people-group"), theme = "primary")
)

ui <- page_navbar(
  title   = TITULO,
  theme   = tema,
  sidebar = barra,
  fillable = FALSE,
  navbar_options = navbar_options(theme = "dark"),   # letras claras sobre la barra oscura

  nav_panel("Resumen", numeros),

  nav_panel("Locales",
            card(card_header("Locales de votación"),
                 DTOutput("t_locales", fill = FALSE))),

  # CONSIGNA 2
  nav_panel("Mapa",
            card(card_header("Lema ganador en cada local"),
                 leafletOutput("mapa", height = "500px")))
)


################################################################################
# SERVIDOR (SERVER)

server <- function(input, output, session) {

  depto_elec <- reactive({
    elecciones[elecciones$departamento == input$depto, ]
  })

  depto_locales <- reactive({
    locales[locales$DepartamentoNombre == input$depto, ]
  })

  # CONSIGNA 1. Igual que los otros dos, pero con la tabla censo.
  depto_censo <- reactive({
    censo[censo$departamento == input$depto, ]
  })

  output$habilitados <- renderText({
    format(depto_elec()$habilitados, big.mark = ".", decimal.mark = ",")
  })

  output$ganador <- renderText({
    depto_elec()$lema_ganador
  })

  output$poblacion <- renderText({
    format(depto_censo()$poblacion_2023, big.mark = ".", decimal.mark = ",")
  })

  # CONSIGNA 3. pageLength cambia las filas, language traduce y
  # rownames = FALSE saca los números de fila.
  output$t_locales <- renderDT({
    l <- depto_locales()[, c("Localidad", "NombreLocal", "TotalHabilitados", "LemaGanador")]
    datatable(l, rownames = FALSE,
              options = list(
                pageLength = 5,
                language   = list(url = "https://cdn.datatables.net/plug-ins/1.13.6/i18n/es-ES.json")
              ))
  })

  # CONSIGNA 2. Igual que el primer mapa de la Clase 7.
  output$mapa <- renderLeaflet({
    l <- depto_locales()
    colores <- colorFactor(COLORES_LEMAS, levels = names(COLORES_LEMAS))
    leaflet(l, options = leafletOptions(scrollWheelZoom = FALSE)) |>
      addProviderTiles("OpenStreetMap") |>
      addCircleMarkers(lng = ~Longitud, lat = ~Latitud, label = ~NombreLocal,
                       color = ~colores(LemaGanador), radius = 5,
                       stroke = FALSE, fillOpacity = 0.8) |>
      addLegend(pal = colores, values = names(COLORES_LEMAS), title = "Lema ganador")
  })
}


################################################################################
shinyApp(ui = ui, server = server)
