# =============================================================================
# EJERCICIO EXTRA 1 - La primera app con otros datos
# Una app con la población por departamento (censo). Hay que cambiarle el
# título, sumarle una columna a la tabla y hacer aparecer un texto.


################################################################################
#RUTA A LOS DATOS
# La app lee las tablas de la carpeta datos/. Antes de empezar, revisá que la
# ruta de abajo lleve a esa carpeta.
#
#   - Si está en ejercicios_extra/, dentro de la carpeta del curso, datos/
#     queda un nivel más arriba. Por eso la ruta empieza con "../"
#   - Si lo guardaste en otro lado, poné la ruta a tu carpeta datos, con
#     barras / y una barra al final. Por ejemplo
#     "C:/Users/tu_usuario/Documents/curso_shiny/datos/"
# Si la ruta está mal, al apretar Run App aparece un error

RUTA_DATOS <- "../datos/"

# apretá Run App y mirá qué aparece. Después andá resolviendo las consignas en 
#orden (están marcadas con CONSIGNA). Guardá y volvé a correr la app después de cada cambio.

library(shiny)



################################################################################
## ZONA DE PRUEBAS

# CONSIGNA 1
# Cambiale el título a la app. Poné uno que diga de qué se trata la tabla.
TITULO <- "Mi app"

################################################################################

# CODIGO ESTATICO
# paste0() pega la ruta del PASO 0 con el nombre del archivo.
censo <- read.csv(paste0(RUTA_DATOS, "censo_departamentos.csv"), encoding = "UTF-8")


################################################################################
# INTERFAZ (UI)

ui <- fluidPage(
  titlePanel(TITULO),
  p("Población de cada departamento según el Censo 2023 (INE)."),
  h3("Población por departamento"),
  tableOutput("tabla_censo")

  # CONSIGNA 3
  # En el server ya está escrito output$total, pero cuando corrés la app no
  # aparece en ningún lado. Por qué?
  # Agregá acá lo que falta para que se vea abajo de la tabla.
  # (ojo con las comas)

)


################################################################################
# SERVIDOR (SERVER)

server <- function(input, output, session) {

  # CONSIGNA 2
  # La tabla muestra solo el departamento y la población de 2023.
  # Sumale la columna de la población de 2011. Los nombres de todas las
  # columnas los podés ver con names(censo) en la consola.
  output$tabla_censo <- renderTable({
    censo[, c("departamento", "poblacion_2023")]
  })

  output$total <- renderText({
    total <- sum(censo$poblacion_2023)
    paste0("En 2023 Uruguay tenía ",
           format(total, big.mark = ".", decimal.mark = ","), " habitantes.")
  })
}

################################################################################
# ARRANCAR LA APP
shinyApp(ui = ui, server = server)

