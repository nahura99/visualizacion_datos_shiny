# =============================================================================
# CLASE 8 · La app final y su publicación
#
# =============================================================================

library(shiny)
library(bslib)
library(ggplot2)   # gráficos
library(plotly)    # gráficos interactivos (zoom y datos al pasar el mouse)
library(DT)        # tablas interactivas (buscar, ordenar, paginar)
library(leaflet)   # mapas interactivos (nuevo)

################################################################################

## ZONA DE PRUEBAS
TITULO <- "Elecciones 2024 · Uruguay"

# COLORES
COLOR_PRINCIPAL  <- "#5A189A"   # cajas de números, barras, botón, links
COLOR_SECUNDARIO <- "#9D4EDD"   # barras de participación
COLOR_FONDO      <- "#FFFFFF"   # fondo de la página
COLOR_TEXTO      <- "#2E0A4E"   # color de las letras
COLOR_NAVEGACION <- "#2E0A4E"   # barra de navegación de arriba

# Tipografías. Cualquier nombre de https://fonts.google.com funciona, por ejemplo "Lato",
# "Roboto Slab", "Playfair Display", "Space Mono" o "Caveat".
FUENTE_TEXTO   <- "Inter"
FUENTE_TITULOS <- "Oswald"

# Lado de la barra lateral, "left" (izquierda) o "right" (derecha)
LADO_BARRA <- "left"

# Menú de regiones. TRUE deja elegir varias, FALSE deja elegir una sola.
REGIONES_MULTIPLES <- TRUE

# Alto de los gráficos y mapas del Resumen y la Dispersión, en píxeles
ALTO_GRAFICO <- "500px"

# Cuándo se actualizan los resultados.
# TRUE  solo al apretar el botón "Aplicar filtros".
# FALSE apenas se mueve un filtro, sin botón.
USAR_BOTON <- TRUE

# Aspecto de los gráficos de ggplot2. Probá theme_classic(), theme_bw(),
# theme_light() o theme_void(). base_size es el tamaño de la letra.
TEMA_GRAFICO <- theme_minimal(base_size = 13)

# Colores de las regiones en los gráficos de puntos. Probá "Set1", "Set2",
# "Paired", "Accent" o "Spectral".
PALETA_REGIONES <- "Dark2"

# Filas que muestran las tablas en cada página. Probá 5 o 19.
FILAS_POR_PAGINA <- 10

# Mapas (nuevo)
# Fondo del mapa. Probá "Esri.WorldGrayCanvas", "Esri.WorldImagery" (satélite)
# o "OpenTopoMap".
FONDO_MAPA <- "OpenStreetMap"
# Tamaño de los puntos (locales de votación)
TAMANO_PUNTOS <- 4
# Colores de los mapas de porcentajes. Probá "Purples", "Blues", "Greens" o "magma".
PALETA_MAPAS <- "viridis"

# Fin de la ZONA DE PRUEBAS ==============================
################################################################################



# ESTÉTICA (explicada en la Clase 7)
tema_curso <- bs_theme(
  version = 5, bg = COLOR_FONDO, fg = COLOR_TEXTO,
  primary = COLOR_PRINCIPAL, secondary = COLOR_SECUNDARIO,
  base_font    = font_google(FUENTE_TEXTO,   local = FALSE),
  heading_font = font_google(FUENTE_TITULOS, local = FALSE),
  "navbar-bg"  = COLOR_NAVEGACION
)

################################################################################

# CODIGO ESTATICO

# Para PUBLICAR la app, los datos tienen que viajar con ella. Por eso esta
# clase tiene su propia carpeta datos/ con una copia de los CSV, y la ruta
# ya no empieza con "../".
elecciones <- read.csv("datos/elecciones_departamento_2024.csv", encoding = "UTF-8")
locales    <- read.csv("datos/elecciones_locales_2024.csv",      encoding = "UTF-8")
censo      <- read.csv("datos/censo_departamentos.csv",          encoding = "UTF-8")

# Nos quedamos con los locales que tienen coordenadas y un lema ganador.
locales <- locales[!is.na(locales$Latitud) & locales$LemaGanador != "", ]

# Vector con las regiones (para el menú desplegable).
regiones <- sort(unique(elecciones$region))

# Colores de los partidos. Se mantienen fijos para no perder su significado.
COLORES_LEMAS <- c("Frente Amplio"    = "#1F4FA3",
                   "Partido Nacional" = "#7FB3E8",
                   "Partido Colorado" = "#D94F3D")

# Opciones de las tablas DT, escritas una sola vez para las cuatro tablas.
# language traduce los textos de la tabla al español.
OPCIONES_TABLAS <- list(
  pageLength = FILAS_POR_PAGINA,
  language   = list(url = "https://cdn.datatables.net/plug-ins/1.13.6/i18n/es-ES.json")
)

# Muestra los números enteros (400000) en vez de notación científica (4e+05).
options(scipen = 999)

# Al publicar, TRUE esconde el detalle técnico de los errores a los visitantes.
# Mientras desarrollás, dejalo en FALSE para ver qué falló.
options(shiny.sanitize.errors = FALSE)




################################################################################
# INTERFAZ (UI)

# Pieza A. La barra lateral (igual que en la Clase 7).
barra <- sidebar(
  title    = "Filtros",
  position = LADO_BARRA,

  selectInput("region", "Región:",
              choices = regiones, selected = regiones,
              multiple = REGIONES_MULTIPLES),

  sliderInput("participacion", "Participación mínima (%):",
              min = 88, max = 92, value = 88, step = 0.5),

  # CSS propio. Oculta las etiquetas 88 y 92 de arriba del deslizador, que
  # repiten lo que ya dice la escala de abajo.
  tags$style(".irs-min, .irs-max { visibility: hidden !important; }"),

  textInput("titulo", "Título del gráfico:", value = "Votos emitidos"),

  if (USAR_BOTON) actionButton("aplicar", "Aplicar filtros", class = "btn-primary"),

  p("Fuente: Corte Electoral e INE")
)

# Pieza B. Los tres números en value_box() (Clase 7).
numeros <- layout_columns(
  value_box("Departamentos", textOutput("n_deptos"),
            showcase = icon("map"), theme = "primary"),
  value_box("Habilitados", textOutput("habilitados"),
            showcase = icon("users"), theme = "primary"),
  value_box("Emitidos", textOutput("emitidos"),
            showcase = icon("check"), theme = "primary")
)

# Piezas C, D y E. Los tres paneles nuevos, con cuatro tarjetas cada uno.
# layout_columns(col_widths = 6) pone las tarjetas de a dos por fila (6 + 6 = 12).

panel_graficos <- layout_columns(
  col_widths = 6,
  card(card_header("Participación y voto al Frente Amplio"),
       plotlyOutput("dispersion")),
  card(card_header("Lema ganador por departamento"),
       plotOutput("g_ganador")),
  card(card_header("Plebiscitos, SÍ al Art. 11 y SÍ al Art. 67"),
       plotOutput("g_plebiscitos")),
  card(card_header("Participación por departamento"),
       plotOutput("g_participacion"))
)

panel_tablas <- layout_columns(
  col_widths = 6,
  card(card_header("Resultados por departamento"),
       DTOutput("tabla", fill = FALSE)),
  card(card_header("Totales por región"),
       DTOutput("t_regiones", fill = FALSE)),
  card(card_header("Locales de votación"),
       DTOutput("t_locales", fill = FALSE)),
  card(card_header("Población (Censos 2011 y 2023)"),
       DTOutput("t_censo", fill = FALSE))
)

panel_mapas <- layout_columns(
  col_widths = 6,
  card(card_header("Lema ganador en cada local de votación"),
       leafletOutput("m_ganador")),
  card(card_header("Voto al Frente Amplio (%)"),
       leafletOutput("m_fa")),
  card(card_header("Voto al Partido Nacional (%)"),
       leafletOutput("m_pn")),
  card(card_header("SÍ al Art. 11 (%)"),
       leafletOutput("m_art11"))
)

# Armamos la página, como en la Clase 7, con tres paneles nuevos.
ui <- page_navbar(
  title    = TITULO,
  theme    = tema_curso,
  sidebar  = barra,
  fillable = FALSE,
  navbar_options = navbar_options(theme = "dark"),

  nav_panel("Resumen",
            numeros,
            card(card_header("Votos emitidos por departamento"),
                 plotOutput("grafico", height = ALTO_GRAFICO))),

  nav_panel("Gráficos", panel_graficos),
  nav_panel("Tablas",   panel_tablas),
  nav_panel("Mapas",    panel_mapas),

  nav_panel("Ayuda",
            card(card_header("Cómo leer estos datos"),
                 p(strong("Habilitados"), "son las personas inscriptas para votar."),
                 p(strong("Emitidos"), "son los votos efectivamente depositados."),
                 p(strong("Participación"), "es emitidos sobre habilitados, en %."),
                 p(strong("Locales de votación"), "son los edificios donde se vota.",
                   "Cada punto de los mapas es uno.")))
)



################################################################################
# SERVIDOR (SERVER)


server <- function(input, output, session) {

  # ---- Los datos filtrados (Clase 5) ----------------------------------------

  datos_filtrados <- reactive({
    req(input$region)
    d <- elecciones[elecciones$region %in% input$region &
                    elecciones$participacion_pct >= input$participacion, ]
    req(nrow(d) > 0)
    d
  })

  datos_con_boton <- eventReactive(input$aplicar, {
    datos_filtrados()
  }, ignoreNULL = FALSE)

  if (USAR_BOTON) {
    datos <- datos_con_boton
  } else {
    datos <- datos_filtrados
  }

  # Nuevo. Los locales y el censo de los departamentos que quedaron en datos().
  # Así los filtros de la barra también mueven las tablas y los mapas.
  locales_filtrados <- reactive({
    locales[locales$DepartamentoNombre %in% datos()$departamento, ]
  })

  censo_filtrado <- reactive({
    censo[censo$departamento %in% datos()$departamento, ]
  })

  # ---- Resumen (Clase 7) ------------------------------------------------------

  output$n_deptos <- renderText({
    nrow(datos())
  })

  output$habilitados <- renderText({
    format(sum(datos()$habilitados), big.mark = ".", decimal.mark = ",")
  })

  output$emitidos <- renderText({
    format(sum(datos()$emitidos), big.mark = ".", decimal.mark = ",")
  })

  output$grafico <- renderPlot({
    ggplot(datos(), aes(x = emitidos, y = reorder(departamento, emitidos))) +
      geom_col(fill = COLOR_PRINCIPAL) +
      labs(title = input$titulo, x = "Votos emitidos", y = NULL) +
      TEMA_GRAFICO
  })

  # ---- Panel de gráficos -----------------------------------------------------

  # 1) Dispersión con plotly (Clase 6).
  output$dispersion <- renderPlotly({
    g <- ggplot(datos(), aes(x = participacion_pct, y = pct_frente_amplio,
                             colour = region, text = departamento)) +
      geom_point(size = 3) +
      scale_colour_brewer(palette = PALETA_REGIONES) +
      labs(x = "Participación (%)", y = "Votos al Frente Amplio (%)", colour = "Región") +
      TEMA_GRAFICO
    ggplotly(g, tooltip = "text")
  })

  # 2) Barras coloreadas por el lema que ganó en cada departamento.
  output$g_ganador <- renderPlot({
    ggplot(datos(), aes(x = pct_ganador, y = reorder(departamento, pct_ganador),
                        fill = lema_ganador)) +
      geom_col() +
      scale_fill_manual(values = COLORES_LEMAS) +
      labs(x = "% del lema ganador", y = NULL, fill = NULL) +
      TEMA_GRAFICO
  })

  # 3) Un punto por departamento con el SÍ a cada plebiscito.
  output$g_plebiscitos <- renderPlot({
    ggplot(datos(), aes(x = pct_si_art11, y = pct_si_art67, colour = region)) +
      geom_point(size = 3) +
      scale_colour_brewer(palette = PALETA_REGIONES) +
      labs(x = "SÍ al Art. 11 (%)", y = "SÍ al Art. 67 (%)", colour = "Región") +
      TEMA_GRAFICO
  })

  # 4) Barras de participación.
  output$g_participacion <- renderPlot({
    ggplot(datos(), aes(x = participacion_pct, y = reorder(departamento, participacion_pct))) +
      geom_col(fill = COLOR_SECUNDARIO) +
      coord_cartesian(xlim = c(85, 93)) +   # empieza en 85 para que se vean las diferencias
      labs(x = "Participación (%)", y = NULL) +
      TEMA_GRAFICO
  })

  # ---- Panel de tablas (DT, Clase 7) -----------------------------------------

  # 1) Por departamento.
  output$tabla <- renderDT({
    d <- datos()[, c("departamento", "region", "habilitados", "emitidos", "participacion_pct")]
    datatable(d, rownames = FALSE, options = OPCIONES_TABLAS)
  })

  # 2) Por región. aggregate() suma las columnas para cada región.
  output$t_regiones <- renderDT({
    r <- aggregate(cbind(habilitados, emitidos) ~ region, data = datos(), FUN = sum)
    datatable(r, rownames = FALSE, options = OPCIONES_TABLAS)
  })

  # 3) Locales de votación.
  output$t_locales <- renderDT({
    l <- locales_filtrados()[, c("DepartamentoNombre", "Localidad", "NombreLocal",
                                 "TotalHabilitados", "LemaGanador")]
    datatable(l, rownames = FALSE, options = OPCIONES_TABLAS)
  })

  # 4) Censo.
  output$t_censo <- renderDT({
    p <- censo_filtrado()[, c("departamento", "poblacion_2011", "poblacion_2023", "variacion_pct")]
    datatable(p, rownames = FALSE, options = OPCIONES_TABLAS)
  })

  # ---- Panel de mapas (leaflet, nuevo) ---------------------------------------
  # Un mapa de leaflet también se arma por partes, unidas con |>
  #   leaflet(datos)              los datos
  #   leafletOptions(scrollWheelZoom = FALSE)  la rueda del mouse no hace zoom,
  #                               así la página baja sin mover el mapa. El zoom
  #                               queda en los botones + y -.
  #   addProviderTiles()          el fondo (calles, satélite...)
  #   addCircleMarkers()          un círculo por local, en Longitud y Latitud
  #   addLegend()                 la leyenda
  # El ~ delante de un nombre (~Latitud) quiere decir "la columna Latitud".
  # colorFactor() y colorNumeric() arman la escala de colores.

  # 1) Lema ganador. colorFactor() da un color a cada categoría.
  output$m_ganador <- renderLeaflet({
    l <- locales_filtrados()
    colores <- colorFactor(COLORES_LEMAS, levels = names(COLORES_LEMAS))
    leaflet(l, options = leafletOptions(scrollWheelZoom = FALSE)) |>
      addProviderTiles(FONDO_MAPA) |>
      addCircleMarkers(lng = ~Longitud, lat = ~Latitud, label = ~NombreLocal,
                       color = ~colores(LemaGanador), radius = TAMANO_PUNTOS,
                       stroke = FALSE, fillOpacity = 0.8) |>
      addLegend(pal = colores, values = names(COLORES_LEMAS), title = "Lema ganador")
  })

  # 2) % Frente Amplio. colorNumeric() va de claro (poco) a oscuro (mucho).
  # domain son los valores que cubre la escala, del mínimo al máximo de la columna.
  output$m_fa <- renderLeaflet({
    l <- locales_filtrados()
    colores <- colorNumeric(PALETA_MAPAS, domain = l$Pct_Frente_Amplio)
    leaflet(l, options = leafletOptions(scrollWheelZoom = FALSE)) |>
      addProviderTiles(FONDO_MAPA) |>
      addCircleMarkers(lng = ~Longitud, lat = ~Latitud, label = ~NombreLocal,
                       color = ~colores(Pct_Frente_Amplio), radius = TAMANO_PUNTOS,
                       stroke = FALSE, fillOpacity = 0.8) |>
      addLegend(pal = colores, values = ~Pct_Frente_Amplio, title = "% FA")
  })

  # 3) % Partido Nacional. Igual que el anterior, cambia la columna.
  output$m_pn <- renderLeaflet({
    l <- locales_filtrados()
    colores <- colorNumeric(PALETA_MAPAS, domain = l$Pct_Partido_Nacional)
    leaflet(l, options = leafletOptions(scrollWheelZoom = FALSE)) |>
      addProviderTiles(FONDO_MAPA) |>
      addCircleMarkers(lng = ~Longitud, lat = ~Latitud, label = ~NombreLocal,
                       color = ~colores(Pct_Partido_Nacional), radius = TAMANO_PUNTOS,
                       stroke = FALSE, fillOpacity = 0.8) |>
      addLegend(pal = colores, values = ~Pct_Partido_Nacional, title = "% PN")
  })

  # 4) SÍ al Art. 11. Igual, cambia la columna.
  output$m_art11 <- renderLeaflet({
    l <- locales_filtrados()
    colores <- colorNumeric(PALETA_MAPAS, domain = l$PctSiArt11)
    leaflet(l, options = leafletOptions(scrollWheelZoom = FALSE)) |>
      addProviderTiles(FONDO_MAPA) |>
      addCircleMarkers(lng = ~Longitud, lat = ~Latitud, label = ~NombreLocal,
                       color = ~colores(PctSiArt11), radius = TAMANO_PUNTOS,
                       stroke = FALSE, fillOpacity = 0.8) |>
      addLegend(pal = colores, values = ~PctSiArt11, title = "% SÍ")
  })

}

################################################################################
# ARRANCAR LA APP
shinyApp(ui = ui, server = server)
