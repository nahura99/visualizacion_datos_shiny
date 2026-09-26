# =============================================================================
# CLASE 6 · Gráficos con ggplot2 y plotly
#
# =============================================================================

library(shiny)
library(bslib)
library(ggplot2)   # gráficos
library(plotly)    # gráficos interactivos (zoom y datos al pasar el mouse)

################################################################################

## ZONA DE PRUEBAS
TITULO <- "Tablero de la Elección Nacional 2024"

# COLORES
COLOR_PRINCIPAL  <- "#5A189A"   # barras del gráfico, botón, pestaña activa, números grandes
COLOR_SECUNDARIO <- "#9D4EDD"
COLOR_FONDO      <- "#FFFFFF"   # fondo de la página
COLOR_TEXTO      <- "#2E0A4E"   # color de las letras

# Tipografías. Cualquier nombre de https://fonts.google.com funciona, por ejemplo "Lato",
# "Roboto Slab", "Playfair Display", "Space Mono" o "Caveat".
FUENTE_TEXTO   <- "Inter"
FUENTE_TITULOS <- "Oswald"

# Lado de la barra lateral, "left" (izquierda) o "right" (derecha)
LADO_BARRA <- "left"

# Estilo de las pestañas, "pills" (botones de color) o "tabs" (solapas)
ESTILO_PESTANAS <- "pills"

# Menú de regiones. TRUE deja elegir varias, FALSE deja elegir una sola.
REGIONES_MULTIPLES <- TRUE

# Alto del gráfico, en píxeles
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

# Formato de la tabla
TABLA_RAYADA  <- TRUE     # filas alternadas con fondo gris
TABLA_BORDES  <- FALSE    # líneas alrededor de cada celda
TABLA_ESPACIO <- "s"      # separación entre filas, "xs", "s", "m" o "l"

# Fin de la ZONA DE PRUEBAS ==============================
################################################################################



# Estética bs_theme() arma el "tema" visual de la app a partir de la zona de pruebas
tema_curso <- bs_theme(
  version = 5, bg = COLOR_FONDO, fg = COLOR_TEXTO,
  primary = COLOR_PRINCIPAL, secondary = COLOR_SECUNDARIO,
  base_font    = font_google(FUENTE_TEXTO,   local = FALSE),
  heading_font = font_google(FUENTE_TITULOS, local = FALSE)
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

# Pieza A. La barra lateral con los inputs (los mismos de la Clase 4).
barra <- sidebarPanel(
  h4("Filtros"),

  selectInput("region", "Región:",
              choices = regiones, selected = regiones,
              multiple = REGIONES_MULTIPLES),

  sliderInput("participacion", "Participación mínima (%):",
              min = 88, max = 92, value = 88, step = 0.5),

  textInput("titulo", "Título del gráfico:", value = "Votos emitidos"),

  # Botón nuevo. Solo aparece si USAR_BOTON es TRUE.
  # Un botón devuelve cuántas veces se apretó (0, 1, 2...).
  if (USAR_BOTON) actionButton("aplicar", "Aplicar filtros", class = "btn-primary"),

  hr(),   # línea divisoria

  p("Fuente: Corte Electoral")
)

# Pieza B. Una fila con tres columnas de números grandes (como en la Clase 3).
numeros <- fluidRow(
  column(4, h5("Departamentos"), h2(textOutput("n_deptos"),    class = "text-primary")),
  column(4, h5("Habilitados"),   h2(textOutput("habilitados"), class = "text-primary")),
  column(4, h5("Emitidos"),      h2(textOutput("emitidos"),    class = "text-primary"))
)

# Pieza C. Las pestañas (las mismas de la Clase 4).
pestanas <- tabsetPanel(
  type = ESTILO_PESTANAS,

  tabPanel("Gráfico",
           br(),
           plotOutput("grafico", height = ALTO_GRAFICO)),

  # Pestaña nueva. plotlyOutput() es como plotOutput(), pero interactivo.
  tabPanel("Dispersión",
           br(),
           p("Pasá el mouse por un punto para ver el departamento.",
             "Arrastrá para hacer zoom y hacé doble clic para volver."),
           plotlyOutput("dispersion", height = ALTO_GRAFICO)),

  tabPanel("Tabla",
           br(),
           tableOutput("tabla")),

  tabPanel("Qué devuelve cada input",
           br(),
           p("Esto es lo que recibe el server. Cambiá los filtros y mirá."),
           verbatimTextOutput("consola")),

  tabPanel("Ayuda",
           br(),
           p(strong("Habilitados"), "son las personas inscriptas para votar."),
           p(strong("Emitidos"), "son los votos efectivamente depositados."),
           p(strong("Participación"), "es emitidos sobre habilitados, en %."))
)

# Armamos la página, igual que en la Clase 3.
ui <- fluidPage(
  theme = tema_curso,

  titlePanel(TITULO),

  sidebarLayout(
    position = LADO_BARRA,
    barra,
    mainPanel(
      numeros,
      hr(),
      pestanas
    )
  )
)



################################################################################
# SERVIDOR (SERVER)


server <- function(input, output, session) {

  # 1) reactive(). El filtro se escribe UNA sola vez.
  # En la Clase 4 lo repetíamos en cada output. Ahora vive acá, y cada output
  # lo usa llamando a datos_filtrados() (con paréntesis, como una función).
  # Se vuelve a calcular solo cuando cambia input$region o input$participacion.
  datos_filtrados <- reactive({
    req(input$region)   # si no hay ninguna región elegida, espera sin error
    d <- elecciones[elecciones$region %in% input$region &
                    elecciones$participacion_pct >= input$participacion, ]
    req(nrow(d) > 0)    # si no queda ningún departamento, espera sin error
    d
  })

  # 2) eventReactive(). Lo mismo, pero se actualiza SOLO al apretar el botón.
  # ignoreNULL = FALSE hace que calcule una vez al abrir la app, sin esperar
  # el primer clic.
  datos_con_boton <- eventReactive(input$aplicar, {
    datos_filtrados()
  }, ignoreNULL = FALSE)

  # Elegimos cuál de los dos usan los outputs (USAR_BOTON, zona de pruebas).
  if (USAR_BOTON) {
    datos <- datos_con_boton
  } else {
    datos <- datos_filtrados
  }

  # De acá para abajo, todos los outputs usan datos().

  output$n_deptos <- renderText({
    nrow(datos())
  })

  output$habilitados <- renderText({
    format(sum(datos()$habilitados), big.mark = ".", decimal.mark = ",")
  })

  output$emitidos <- renderText({
    format(sum(datos()$emitidos), big.mark = ".", decimal.mark = ",")
  })

  # El mismo gráfico de barras de la Clase 5, ahora con ggplot2.
  # Un ggplot se arma por capas que se suman con +.
  #   ggplot(datos, aes(...)) dice qué columna va en cada eje.
  #   geom_col() dibuja las barras.
  #   labs() pone los títulos y TEMA_GRAFICO el aspecto general.
  # reorder(departamento, emitidos) ordena los nombres según los votos.
  output$grafico <- renderPlot({
    ggplot(datos(), aes(x = emitidos, y = reorder(departamento, emitidos))) +
      geom_col(fill = COLOR_PRINCIPAL) +
      labs(title = input$titulo, x = "Votos emitidos", y = NULL) +
      TEMA_GRAFICO
  })

  # Gráfico nuevo. Un punto por departamento, coloreado por región.
  # Se arma igual que un ggplot y ggplotly() lo vuelve interactivo.
  # tooltip = "text" muestra solo el departamento al pasar el mouse.
  output$dispersion <- renderPlotly({
    g <- ggplot(datos(), aes(x = participacion_pct, y = pct_frente_amplio,
                             colour = region, text = departamento)) +
      geom_point(size = 4) +
      scale_colour_brewer(palette = PALETA_REGIONES) +
      labs(x = "Participación (%)", y = "Votos al Frente Amplio (%)", colour = "Región") +
      TEMA_GRAFICO
    ggplotly(g, tooltip = "text")
  })

  output$tabla <- renderTable({
    d <- datos()
    d[order(-d$emitidos),
      c("departamento", "region", "habilitados", "emitidos", "participacion_pct")]
  },
  striped  = TABLA_RAYADA,
  bordered = TABLA_BORDES,
  spacing  = TABLA_ESPACIO
  )

  # Lo que recibe el server de cada input.
  output$consola <- renderPrint({
    list(
      region        = input$region,
      participacion = input$participacion,
      titulo        = input$titulo,
      aplicar       = as.numeric(input$aplicar)   # as.numeric() muestra solo el número
    )
  })
}

################################################################################
# ARRANCAR LA APP
shinyApp(ui = ui, server = server)
