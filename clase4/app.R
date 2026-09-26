# =============================================================================
# CLASE 4 · Entradas (inputs) y salidas (outputs)
#
# =============================================================================

library(shiny)
library(bslib)

################################################################################

## ZONA DE PRUEBAS
TITULO <- "Tablero de la Elección Nacional 2024"

# COLORES
COLOR_PRINCIPAL  <- "#5A189A"   # barras del gráfico, pestaña activa, números grandes
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
# Mirá en la pestaña "Qué devuelve cada input" cómo cambia el valor.
REGIONES_MULTIPLES <- TRUE

# Alto del gráfico, en píxeles
ALTO_GRAFICO <- "400px"

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

# Pieza A. La barra lateral con los tres INPUTS.
# Cada input tiene un id (el primer argumento) y el server lo lee con input$id.
barra <- sidebarPanel(
  h4("Filtros"),

  # 1) Menú desplegable. Devuelve un texto, o varios si multiple = TRUE.
  selectInput("region", "Región:",
              choices = regiones, selected = regiones,
              multiple = REGIONES_MULTIPLES),

  # 2) Deslizador. Devuelve un número.
  sliderInput("participacion", "Participación mínima (%):",
              min = 88, max = 92, value = 88, step = 0.5),

  # 3) Texto libre. Devuelve lo que se escriba.
  textInput("titulo", "Título del gráfico:", value = "Votos emitidos"),

  hr(),   # línea divisoria

  p("Fuente: Corte Electoral")
)

# Pieza B. Una fila con tres columnas de números grandes (como en la Clase 3).
numeros <- fluidRow(
  column(4, h5("Departamentos"), h2(textOutput("n_deptos"),    class = "text-primary")),
  column(4, h5("Habilitados"),   h2(textOutput("habilitados"), class = "text-primary")),
  column(4, h5("Emitidos"),      h2(textOutput("emitidos"),    class = "text-primary"))
)

# Pieza C. Las pestañas. Cada una muestra un tipo de OUTPUT distinto.
# Cada output reserva un lugar con un id, y el server lo rellena.
pestanas <- tabsetPanel(
  type = ESTILO_PESTANAS,

  tabPanel("Gráfico",
           br(),
           plotOutput("grafico", height = ALTO_GRAFICO)),

  tabPanel("Tabla",
           br(),
           tableOutput("tabla")),

  tabPanel("Qué devuelve cada input",
           br(),
           p("Esto es lo que recibe el server. Cambiá los filtros y mirá."),
           verbatimTextOutput("consola"))
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

  # Cada output tiene su función render. textOutput va con renderText,
  # plotOutput con renderPlot, tableOutput con renderTable y
  # verbatimTextOutput con renderPrint.

  # Todos repiten el mismo filtro, por región y por participación mínima.
  # Más adelante aprendemos a escribirlo una sola vez.

  output$n_deptos <- renderText({
    d <- elecciones[elecciones$region %in% input$region &
                    elecciones$participacion_pct >= input$participacion, ]
    nrow(d)
  })

  output$habilitados <- renderText({
    d <- elecciones[elecciones$region %in% input$region &
                    elecciones$participacion_pct >= input$participacion, ]
    format(sum(d$habilitados), big.mark = ".", decimal.mark = ",")
  })

  output$emitidos <- renderText({
    d <- elecciones[elecciones$region %in% input$region &
                    elecciones$participacion_pct >= input$participacion, ]
    format(sum(d$emitidos), big.mark = ".", decimal.mark = ",")
  })

  # Un gráfico de barras hecho con R base. El título sale del textInput.
  output$grafico <- renderPlot({
    d <- elecciones[elecciones$region %in% input$region &
                    elecciones$participacion_pct >= input$participacion, ]
    req(nrow(d) > 0)           # si no queda ningún departamento, no dibuja nada
    d <- d[order(d$emitidos), ]
    par(mar = c(4, 9, 3, 1))   # deja lugar a la izquierda para los nombres
    barplot(d$emitidos, names.arg = d$departamento, horiz = TRUE, las = 1,
            col = COLOR_PRINCIPAL, border = NA, main = input$titulo)
  })

  output$tabla <- renderTable({
    d <- elecciones[elecciones$region %in% input$region &
                    elecciones$participacion_pct >= input$participacion, ]
    d[order(-d$emitidos),
      c("departamento", "region", "habilitados", "emitidos", "participacion_pct")]
  },
  striped  = TABLA_RAYADA,
  bordered = TABLA_BORDES,
  spacing  = TABLA_ESPACIO
  )

  # renderPrint() muestra lo mismo que R mostraría en la consola.
  output$consola <- renderPrint({
    list(
      region        = input$region,
      participacion = input$participacion,
      titulo        = input$titulo
    )
  })
}

################################################################################
# ARRANCAR LA APP
shinyApp(ui = ui, server = server)
