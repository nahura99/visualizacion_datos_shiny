# =============================================================================
# CLASE 2 · Bases de RStudio y Shiny
#
# =============================================================================

library(shiny)
library(bslib)

################################################################################

## ZONA DE PRUEBAS
TITULO <- "Mi primera app Shiny"

# COLORES
COLOR_PRINCIPAL  <- "#5A189A"   # casillas marcadas, links, botones
COLOR_SECUNDARIO <- "#9D4EDD"
COLOR_FONDO      <- "#FFFFFF"   # fondo de la página
COLOR_TEXTO      <- "#2E0A4E"   # color de las letras

# Tipografías. Cualquier nombre de https://fonts.google.com funciona, por ejemplo "Lato",
# "Roboto Slab", "Playfair Display", "Space Mono" o "Caveat".
FUENTE_TEXTO   <- "Inter"
FUENTE_TITULOS <- "Oswald"

# Disposición "simple", "lateral", "columnas"
LAYOUT <- "simple"

# Formato de la tabla
TABLA_RAYADA  <- FALSE    # filas alternadas con fondo gris
TABLA_BORDES  <- TRUE   # líneas alrededor de cada celda
TABLA_ESPACIO <- "xs"     # separación entre filas, "xs", "s", "m" o "l"

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

#Ruta relativa para cubrir 
elecciones <- read.csv("../datos/elecciones_departamento_2024.csv", encoding = "UTF-8")

# Vector con los nombres de los 19 departamentos (para el menú desplegable).
departamentos <- sort(elecciones$departamento)




################################################################################
# INTERFAZ (UI)

# Pieza A. Los controles.
# Un INPUT, el usuario elige un departamento. El id ("depto") es la llave con
# la que el server va a leer el valor elegido, input$depto.
controles <- selectInput(
  inputId  = "depto",
  label    = "Elegí un departamento:",
  choices  = departamentos,
  selected = "Montevideo"
)

# Pieza B. Los resultados.
# Dos OUTPUTS, espacios vacíos que el server va a rellenar. Cada uno tiene un
# id ("ficha", "tabla") que el server usa para saber dónde escribir.
resultados <- tagList(
  h3("Ficha del departamento"),
  textOutput("ficha"),

  h3("Votos emitidos por departamento"),
  tableOutput("tabla")
)

# Acomodamos las piezas A y B según el LAYOUT (ZONA DE PRUEBAS).
cuerpo <- switch(
  LAYOUT,
  simple   = tagList(controles, resultados),
  lateral  = sidebarLayout(sidebarPanel(controles), mainPanel(resultados)),
  columnas = fluidRow(column(6, controles), column(6, resultados)),
  stop("LAYOUT tiene que ser \"simple\", \"lateral\" o \"columnas\".")
)

ui <- fluidPage(
  theme = tema_curso,

  titlePanel(TITULO),

  # Texto estático, escrito directamente en la interfaz.
  p("La app más simple posible. Un título, un menú, un texto y una tabla."),
  p("Datos de la Elección Nacional 2024, Uruguay (Corte Electoral)."),

  cuerpo
)



################################################################################
# SERVIDOR (SERVER)


server <- function(input, output, session) {

  # Este bloque se vuelve a correr cada vez que cambia input$depto.
  output$ficha <- renderText({
    fila <- elecciones[elecciones$departamento == input$depto, ]
    paste0(
      "En ", fila$departamento, " votaron ",
      format(fila$emitidos, big.mark = ".", decimal.mark = ","), " personas (",
      fila$participacion_pct, "% de participación). ",
      "El lema más votado fue ", fila$lema_ganador,
      " con ", fila$pct_ganador, "% de los votos."
    )
  })

  # Este bloque NO depende de ningún input, se corre una vez y queda fijo.
  # Los argumentos que van después de las llaves {} dan formato a la tabla y
  # salen de la ZONA DE PRUEBAS.
  
  output$tabla <- renderTable({
    elecciones[order(-elecciones$emitidos),
               c("departamento", "region", "emitidos", "participacion_pct")]
  },
  striped  = TABLA_RAYADA,
  bordered = TABLA_BORDES,
  spacing  = TABLA_ESPACIO
  )
}

################################################################################
# ARRANCAR LA APP
shinyApp(ui = ui, server = server)
