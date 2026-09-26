# =============================================================================
# CLASE 7 · Estética y navegación
#
# =============================================================================

library(shiny)
library(bslib)
library(ggplot2)   # gráficos
library(plotly)    # gráficos interactivos (zoom y datos al pasar el mouse)
library(DT)        # tablas interactivas (buscar, ordenar, paginar)

################################################################################

## ZONA DE PRUEBAS
TITULO <- "Elecciones 2024 · Uruguay"

# COLORES
COLOR_PRINCIPAL  <- "#5A189A"   # cajas de números, barras, botón, links
COLOR_SECUNDARIO <- "#9D4EDD"
COLOR_FONDO      <- "#FFFFFF"   # fondo de la página
COLOR_TEXTO      <- "#2E0A4E"   # color de las letras
COLOR_NAVEGACION <- "#2E0A4E"   # barra de navegación de arriba (nuevo)

# Tipografías. Cualquier nombre de https://fonts.google.com funciona, por ejemplo "Lato",
# "Roboto Slab", "Playfair Display", "Space Mono" o "Caveat".
FUENTE_TEXTO   <- "Inter"
FUENTE_TITULOS <- "Oswald"

# Lado de la barra lateral, "left" (izquierda) o "right" (derecha)
LADO_BARRA <- "left"

# Menú de regiones. TRUE deja elegir varias, FALSE deja elegir una sola.
REGIONES_MULTIPLES <- TRUE

# Alto de los gráficos, en píxeles
ALTO_GRAFICO <- "500px"

# Cuándo se actualizan los resultados.
# TRUE  solo al apretar el botón "Aplicar filtros".
# FALSE apenas se mueve un filtro, sin botón.
USAR_BOTON <- TRUE

# Aspecto de los gráficos de ggplot2. Probá theme_classic(), theme_bw(),
# theme_light() o theme_void(). base_size es el tamaño de la letra.
TEMA_GRAFICO <- theme_minimal(base_size = 14)

# Colores de las regiones en el gráfico de dispersión. Probá "Set1", "Set2",
# "Paired", "Accent" o "Spectral".
PALETA_REGIONES <- "Dark2"

# Filas que muestra la tabla en cada página (nuevo). Probá 5 o 19.
FILAS_POR_PAGINA <- 10

# Fin de la ZONA DE PRUEBAS ==============================
################################################################################



# ESTÉTICA
# Desde la Clase 2 venimos usando este bloque. Hoy lo explicamos.
# bs_theme() arma un "tema" de Bootstrap, el sistema de estilos que usa Shiny.
# Cada argumento cambia una parte de TODA la app a la vez.
#   bg y fg           fondo y letra
#   primary           el color principal (botones, links, cajas)
#   secondary         un segundo color
#   base_font         la letra del texto
#   heading_font      la letra de los títulos
#   "navbar-bg"       cualquier variable de Bootstrap va entre comillas
tema_curso <- bs_theme(
  version = 5, bg = COLOR_FONDO, fg = COLOR_TEXTO,
  primary = COLOR_PRINCIPAL, secondary = COLOR_SECUNDARIO,
  base_font    = font_google(FUENTE_TEXTO,   local = FALSE),
  heading_font = font_google(FUENTE_TITULOS, local = FALSE),
  "navbar-bg"  = COLOR_NAVEGACION
)

################################################################################

# CODIGO ESTATICO

elecciones <- read.csv("../datos/elecciones_departamento_2024.csv", encoding = "UTF-8")

# Vector con las regiones (para el menú desplegable).
regiones <- sort(unique(elecciones$region))

# Muestra los números enteros (400000) en vez de notación científica (4e+05).
options(scipen = 999)




################################################################################
# INTERFAZ (UI)

# Pieza A. La barra lateral. Mismos controles que antes, pero ahora con
# sidebar() de bslib en lugar de sidebarPanel(). Se puede plegar con la flecha.
barra <- sidebar(
  title    = "Filtros",
  position = LADO_BARRA,

  selectInput("region", "Región:",
              choices = regiones, selected = regiones,
              multiple = REGIONES_MULTIPLES),

  sliderInput("participacion", "Participación mínima (%):",
              min = 88, max = 92, value = 88, step = 0.5),

  textInput("titulo", "Título del gráfico:", value = "Votos emitidos"),

  # Solo aparece si USAR_BOTON es TRUE.
  if (USAR_BOTON) actionButton("aplicar", "Aplicar filtros", class = "btn-primary"),

  p("Fuente: Corte Electoral")
)

# Pieza B. Los tres números, ahora en value_box().
# Una value_box es una caja de color con un título, un valor y un ícono.
# theme = "primary" la pinta con COLOR_PRINCIPAL.
# layout_columns() las pone una al lado de la otra.
numeros <- layout_columns(
  value_box("Departamentos", textOutput("n_deptos"),
            showcase = icon("map"), theme = "primary"),
  value_box("Habilitados", textOutput("habilitados"),
            showcase = icon("users"), theme = "primary"),
  value_box("Emitidos", textOutput("emitidos"),
            showcase = icon("check"), theme = "primary")
)

# Armamos la página con page_navbar().
# Cambia la forma de la página. Las pestañas pasan a una barra de navegación
# arriba, y cada una es un nav_panel(). Los gráficos van dentro de card(),
# tarjetas con un título (card_header).
ui <- page_navbar(
  title    = TITULO,
  theme    = tema_curso,
  sidebar  = barra,
  fillable = FALSE,   # cada pestaña crece hacia abajo, como una página común
  navbar_options = navbar_options(theme = "dark"),   # letras claras sobre la barra oscura

  nav_panel("Resumen",
            numeros,
            card(card_header("Votos emitidos por departamento"),
                 plotOutput("grafico", height = ALTO_GRAFICO))),

  nav_panel("Dispersión",
            card(card_header("Participación y voto al Frente Amplio"),
                 p("Pasá el mouse por un punto para ver el departamento."),
                 plotlyOutput("dispersion", height = ALTO_GRAFICO))),

  nav_panel("Tabla",
            card(card_header("Resultados por departamento"),
                 DTOutput("tabla", fill = FALSE))),

  nav_panel("Qué devuelve cada input",
            card(card_header("Esto es lo que recibe el server"),
                 verbatimTextOutput("consola"))),

  nav_panel("Ayuda",
            card(card_header("Cómo leer estos datos"),
                 p(strong("Habilitados"), "son las personas inscriptas para votar."),
                 p(strong("Emitidos"), "son los votos efectivamente depositados."),
                 p(strong("Participación"), "es emitidos sobre habilitados, en %.")))
)



################################################################################
# SERVIDOR (SERVER)
# Casi igual que en la Clase 6. Solo cambia la tabla, que ahora es DT.


server <- function(input, output, session) {

  # El filtro, una sola vez (Clase 5).
  datos_filtrados <- reactive({
    req(input$region)
    d <- elecciones[elecciones$region %in% input$region &
                    elecciones$participacion_pct >= input$participacion, ]
    req(nrow(d) > 0)
    d
  })

  # La misma idea, pero solo al apretar el botón (Clase 5).
  datos_con_boton <- eventReactive(input$aplicar, {
    datos_filtrados()
  }, ignoreNULL = FALSE)

  if (USAR_BOTON) {
    datos <- datos_con_boton
  } else {
    datos <- datos_filtrados
  }

  output$n_deptos <- renderText({
    nrow(datos())
  })

  output$habilitados <- renderText({
    format(sum(datos()$habilitados), big.mark = ".", decimal.mark = ",")
  })

  output$emitidos <- renderText({
    format(sum(datos()$emitidos), big.mark = ".", decimal.mark = ",")
  })

  # Barras con ggplot2 (Clase 6).
  output$grafico <- renderPlot({
    ggplot(datos(), aes(x = emitidos, y = reorder(departamento, emitidos))) +
      geom_col(fill = COLOR_PRINCIPAL) +
      labs(title = input$titulo, x = "Votos emitidos", y = NULL) +
      TEMA_GRAFICO
  })

  # Dispersión con plotly (Clase 6).
  output$dispersion <- renderPlotly({
    g <- ggplot(datos(), aes(x = participacion_pct, y = pct_frente_amplio,
                             colour = region, text = departamento)) +
      geom_point(size = 4) +
      scale_colour_brewer(palette = PALETA_REGIONES) +
      labs(x = "Participación (%)", y = "Votos al Frente Amplio (%)", colour = "Región") +
      TEMA_GRAFICO
    ggplotly(g, tooltip = "text")
  })

  # Tabla nueva con DT. En la app se puede buscar, ordenar haciendo clic en
  # una columna y pasar de página.
  # rownames = FALSE saca la columna de números de fila.
  # language traduce los textos de la tabla al español.
  output$tabla <- renderDT({
    d <- datos()
    d <- d[, c("departamento", "region", "habilitados", "emitidos", "participacion_pct")]
    datatable(d, rownames = FALSE,
              options = list(pageLength = FILAS_POR_PAGINA,
                             language = list(url = "https://cdn.datatables.net/plug-ins/1.13.6/i18n/es-ES.json")))
  })

  output$consola <- renderPrint({
    list(
      region        = input$region,
      participacion = input$participacion,
      titulo        = input$titulo,
      aplicar       = as.numeric(input$aplicar)
    )
  })
}

################################################################################
# ARRANCAR LA APP
shinyApp(ui = ui, server = server)
