# =============================================================================
# CLASE 3 · Interfaz de usuario (UI)
#
# =============================================================================

library(shiny)
library(bslib)

################################################################################

## ZONA DE PRUEBAS
TITULO <- "Tablero de la Elección Nacional 2024"

# COLORES
COLOR_PRINCIPAL  <- "#5A189A"   # pestaña activa, números grandes, links
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




################################################################################
# INTERFAZ (UI)

# Pieza A. La barra lateral.
# Tiene el único INPUT de la app (el filtro de región) y texto HTML que guía
# al usuario. h4(), p(), strong(), em(), hr() y a() son etiquetas HTML
# escritas desde R.
barra <- sidebarPanel(
  h4("Filtros"),
  selectInput("region", "Región:",
              choices = regiones, selected = regiones, multiple = TRUE),

  hr(),   # línea divisoria

  h4("Datos"),
  p("Resultados de la Elección Nacional 2024"), 
  p("Fuente: Corte Electoral"),
)

# Pieza B. Una fila con tres columnas.
# fluidRow() arma una fila y column() la divide. La pantalla tiene 12 columnas,
# así que tres columnas de 4 ocupan todo el ancho.
# class = "text-primary" pinta el número con COLOR_PRINCIPAL.
numeros <- fluidRow(
  column(4, h5("Departamentos"), h2(textOutput("n_deptos"),    class = "text-primary")),
  column(4, h5("Habilitados"),   h2(textOutput("habilitados"), class = "text-primary")),
  column(4, h5("Emitidos"),      h2(textOutput("emitidos"),    class = "text-primary"))
)

# Pieza C. Las pestañas. Cada tabPanel() es una pestaña con su contenido.
pestanas <- tabsetPanel(
  type = ESTILO_PESTANAS,

  tabPanel("Tabla",
           br(),
           tableOutput("tabla")),

  tabPanel("Ayuda",
           br(),
           p(strong("Habilitados"), "son las personas inscriptas para votar."),
           p(strong("Emitidos"), "son los votos efectivamente depositados."),
           p(strong("Participación"), "es emitidos sobre habilitados, en %."))
)

# Armamos la página. sidebarLayout() pone la barra (pieza A) a un lado y el
# panel principal (piezas B y C) al otro.
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

  # Todos estos bloques se vuelven a correr cada vez que cambia input$region.
  # Repetimos el mismo filtro en cada uno. En la Clase 6 aprendemos a
  # escribirlo una sola vez.

  output$n_deptos <- renderText({
    d <- elecciones[elecciones$region %in% input$region, ]
    nrow(d)
  })

  output$habilitados <- renderText({
    d <- elecciones[elecciones$region %in% input$region, ]
    format(sum(d$habilitados), big.mark = ".", decimal.mark = ",")
  })

  output$emitidos <- renderText({
    d <- elecciones[elecciones$region %in% input$region, ]
    format(sum(d$emitidos), big.mark = ".", decimal.mark = ",")
  })

  output$tabla <- renderTable({
    d <- elecciones[elecciones$region %in% input$region, ]
    d[order(-d$emitidos),
      c("departamento", "region", "habilitados", "emitidos", "participacion_pct")]
  },
  striped  = TABLA_RAYADA,
  bordered = TABLA_BORDES,
  spacing  = TABLA_ESPACIO
  )
}

################################################################################
# ARRANCAR LA APP
shinyApp(ui = ui, server = server)
