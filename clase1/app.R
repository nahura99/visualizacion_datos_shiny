# =====================================================================
# CLASE 1 - Presentación del curso y primeros pasos

# Una app Shiny SIEMPRE tiene tres piezas.
#   1) ui      - Lo que se ve (la interfaz).
#   2) server  - Lo que hace (la lógica de la app).
#   3) shinyApp(ui, server) código que las une y arranca la app.


################################################################################

library(shiny)

## ZONA DE PRUEBAS
TITULO <- "Mi primera app Shiny" # Cambiá el texto entre comillas, guardá y volvé a apretar Run App.

################################################################################

# CODIGO ESTATICO. Esto se ejecuta UNA sola vez, cuando arranca la app. No depende del usuario.
# read.csv() lee una tabla guardada como texto separado por comas y la guarda
# en el objeto elecciones (un data frame, 19 filas, una por departamento).

elecciones <- read.csv("../datos/elecciones_departamento_2024.csv", encoding = "UTF-8")
# La ruta empieza con ".." porque Run App se para en la carpeta clase1/ y los
# datos están un nivel más arriba, en datos/.



################################################################################
# INTERFAZ (UI)
# fluidPage() arma una página que se adapta al ancho de la pantalla. Todo lo que
# va adentro, separado por comas, aparece de arriba hacia abajo.

ui <- fluidPage(

  # El título de la página.Sale de la zona de pruebas.
  titlePanel(TITULO),

  # Texto fijo. p() es un párrafo, igual que en una página web.
  p("Esta es la app más simple posible. Es un título, un texto y una tabla."),
  p("Los datos salen de la Elección Nacional 2024 de Uruguay (Corte Electoral)."),

  # h3() es un subtítulo.
  h3("Votos emitidos por departamento"),

  # Un OUTPUT es un espacio vacío que el server va a rellenar. Se reconoce
  # por el id entre comillas en este caso "tabla_elecciones"
  tableOutput("tabla_elecciones"),

  # Otro output, esta vez para un texto calculado.
  textOutput("resumen")
)


################################################################################
# SERVIDOR (SERVER)
# El server rellena los outputs de la UI. Cada output$id <- render...() escribe
# en el espacio que tiene ese mismo id. Si los nombres no coinciden, no aparece
# nada.

server <- function(input, output, session) {

  # renderTable() devuelve una tabla. Elegimos dos columnas del data frame.
  output$tabla_elecciones <- renderTable({
    elecciones[, c("departamento", "emitidos")]
  })

  # renderText() devuelve un texto. sum() suma la columna emitidos y format()
  # le pone el punto de los miles.
  output$resumen <- renderText({
    total <- sum(elecciones$emitidos)
    paste0("Votos emitidos en total: ",
           format(total, big.mark = ".", decimal.mark = ","), " votos.")
  })
}


################################################################################
# ARRANCAR LA APP
shinyApp(ui = ui, server = server)
