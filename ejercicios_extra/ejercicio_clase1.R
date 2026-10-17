# =============================================================================
# EJERCICIO EXTRA 1 · La primera app con otros datos
# Una app con la población por departamento (censo). Hay que cambiarle el
# título, sumarle una columna a la tabla y hacer aparecer un texto.
# =============================================================================

# Para hacer después de la Clase 1.
# Es la misma idea que la app de la clase, pero con otra tabla, la del censo.
# Abrí el archivo, apretá Run App y mirá qué aparece. Después andá resolviendo
# las consignas en orden (están marcadas con CONSIGNA). Guardá y volvé a correr
# la app después de cada cambio.

library(shiny)

################################################################################
## ZONA DE PRUEBAS

# CONSIGNA 1
# Cambiale el título a la app. Poné uno que diga de qué se trata la tabla.
TITULO <- "Mi app"

################################################################################

# CODIGO ESTATICO
# Igual que en la clase, la ruta empieza con ".." porque los datos están en
# la carpeta datos/, un nivel más arriba.
censo <- read.csv("../datos/censo_departamentos.csv", encoding = "UTF-8")


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
  # Agregá acá lo que falta para que se vea, abajo de la tabla.
  # (ojo con la coma, cada cosa dentro de fluidPage() va separada por comas)

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

# Si te sobra tiempo... probá agregar otro p() con la fuente de los datos
# en un lugar distinto de la página.
