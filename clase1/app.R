# =============================================================================
# CLASE 1 — Bases de RStudio y Shiny
#
# Una app Shiny SIEMPRE tiene tres piezas:
#   1) ui      -> qué se ve (la interfaz).
#   2) server  -> qué hace (la lógica).
#   3) shinyApp(ui, server) -> las une y arranca la app.
# =============================================================================

## LIBRERIAS
library(shiny)


## CODIGO ESTÁTICO
# Esto se ejecuta UNA sola vez, cuando arranca la app (no es reactivo).
# Leemos los resultados por departamento de la Elección Nacional 2024 (Corte
# Electoral).
elecciones <- read.csv("../datos/elecciones_departamento_2024.csv", encoding = "UTF-8")


## 1.
## INTERFAZ DE USUARIO (UI)
ui <- fluidPage(
  titlePanel("Mi primera app Shiny"),

  # Un texto de bienvenida
  p("Esta es la app más simple posible. Es un título, un texto y una tabla."),
  p("Los datos salen de la Elección Nacional 2024 de Uruguay (Corte Electoral)."),

  # Un espacio (output) que será rellenado por el server
  h3("Votos emitidos por departamento"),
  tableOutput("tabla_elecciones"),

  # Otro output de texto dinámico
  textOutput("resumen")
)


## 2.
## SERVIDOR (server)
# El server "rellena" los outputs que definimos en la UI.

server <- function(input, output, session) {

  # Rellenamos el output "tabla_elecciones" con render*().
  output$tabla_elecciones <- renderTable({
    elecciones[, c("departamento", "emitidos")]
  })

  # Rellenamos el output "resumen" con un texto calculado.
  output$resumen <- renderText({
    total <- sum(elecciones$emitidos)
    paste0("Votos emitidos en total: ",
           format(total, big.mark = "."), " votos.")
  })
}


## ARRANCAR LA APP
shinyApp(ui = ui, server = server)
