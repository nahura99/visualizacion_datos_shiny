# =============================================================================
# SOLUCIÓN · EJERCICIO EXTRA 7 · Un tablero por departamento

RUTA_DATOS <- "../datos/"

################################################################################

library(shiny)
library(bslib)
library(DT)
library(leaflet)

TITULO <- "Mi departamento en 2024"

################################################################################

# Consigna 4, color de la barra y fuente de los títulos en el tema
tema <- bs_theme(version = 5, bg = "#FFFFFF", fg = "#2E0A4E", primary = "#5A189A",
                 heading_font = font_google("Oswald", local = FALSE),
                 "navbar-bg" = "#2E0A4E")

elecciones <- read.csv(paste0(RUTA_DATOS, "elecciones_departamento_2024.csv"), encoding = "UTF-8")
locales    <- read.csv(paste0(RUTA_DATOS, "elecciones_locales_2024.csv"), encoding = "UTF-8")
censo      <- read.csv(paste0(RUTA_DATOS, "censo_departamentos.csv"), encoding = "UTF-8")
locales    <- locales[!is.na(locales$Latitud), ]

COLORES_LEMAS <- c("Frente Amplio"    = "#1F4FA3",
                   "Partido Nacional" = "#7FB3E8",
                   "Partido Colorado" = "#D94F3D")

################################################################################

barra <- sidebar(title = "Filtro",
  selectInput("depto", "Departamento:", choices = sort(elecciones$departamento), selected = "Florida"),
  p("Fuente: Corte Electoral e INE"))

numeros <- layout_columns(
  value_box("Habilitados",    textOutput("habilitados"), showcase = icon("users"),        theme = "primary"),
  value_box("Lema ganador",   textOutput("ganador"),     showcase = icon("check"),        theme = "primary"),
  value_box("Población 2023", textOutput("poblacion"),   showcase = icon("people-group"), theme = "primary")   # Consigna 1
)

ui <- page_navbar(
  title = TITULO, theme = tema, sidebar = barra, fillable = FALSE,
  navbar_options = navbar_options(theme = "dark"),   # letras claras sobre la barra oscura
  nav_panel("Resumen", numeros),
  nav_panel("Locales", card(card_header("Locales de votación"), DTOutput("t_locales", fill = FALSE))),
  nav_panel("Mapa", card(card_header("Lema ganador en cada local"),                                  # Consigna 2
                         leafletOutput("mapa", height = "500px")))
)

################################################################################

server <- function(input, output, session) {
  depto_elec <- reactive({
    elecciones[elecciones$departamento == input$depto, ]
  })
  depto_locales <- reactive({
    locales[locales$DepartamentoNombre == input$depto, ]
  })
  depto_censo <- reactive({   # Consigna 1, igual que los otros dos
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

  # Consigna 3, 5 filas, en español y sin números de fila
  output$t_locales <- renderDT({
    l <- depto_locales()[, c("Localidad", "NombreLocal", "TotalHabilitados", "LemaGanador")]
    datatable(l, rownames = FALSE,
              options = list(pageLength = 5,
                             language = list(url = "https://cdn.datatables.net/plug-ins/1.13.6/i18n/es-ES.json")))
  })

  # Consigna 2, un punto por local con el color del lema ganador
  output$mapa <- renderLeaflet({
    l <- depto_locales()
    colores <- colorFactor(COLORES_LEMAS, levels = names(COLORES_LEMAS))
    leaflet(l) |>
      addProviderTiles("OpenStreetMap") |>
      addCircleMarkers(lng = ~Longitud, lat = ~Latitud, label = ~NombreLocal,
                       color = ~colores(LemaGanador), radius = 5, stroke = FALSE, fillOpacity = 0.8) |>
      addLegend(pal = colores, values = names(COLORES_LEMAS), title = "Lema ganador")
  })
}

################################################################################

shinyApp(ui, server)
