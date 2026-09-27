################################################################################
# CLASE DE PREPARACIÓN - La app más chica posible. Tres piezas.
library(shiny)

################################################################################
## ZONA DE PRUEBAS
TITULO  <- "Hola, Shiny"
MENSAJE <- "Esta es mi primera app."

# INTERFAZ (UI)
ui <- fluidPage(
  h1(TITULO, style = "background: white"), # probar "red", "blue", "green"
  p(MENSAJE),
  p("Todo lo que ves acá está escrito en R.")
)

# SERVIDOR (SERVER) Por ahora está vacío, la app no calcula nada.
server <- function(input, output, session) {
}

# CÓDIGO PARAARRANCAR LA APP
shinyApp(ui = ui, server = server)

################################################################################
