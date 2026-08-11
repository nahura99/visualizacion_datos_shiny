# =============================================================================
# CLASE 1 — Bases de RStudio y Shiny
# Curso: Visualización interactiva de datos con R y Shiny (Udelar)
# -----------------------------------------------------------------------------
# Objetivo de la clase:
#   - Entender la arquitectura mínima de una app Shiny: ui + server + shinyApp().
#   - Distinguir código ESTÁTICO (se corre una vez) de código REACTIVO
#     (se recalcula cuando el usuario interactúa).
#
# Una app Shiny SIEMPRE tiene tres piezas:
#   1) ui      -> qué se ve (la interfaz).
#   2) server  -> qué hace (la lógica).
#   3) shinyApp(ui, server) -> las une y arranca la app.
# =============================================================================

library(shiny)

# --- Código ESTÁTICO --------------------------------------------------------
# Esto se ejecuta UNA sola vez, cuando arranca la app (no es reactivo).
# Leemos el dataset del Censo 2023 (INE). La ruta funciona tanto si corrés la
# app desde la carpeta de la clase como desde la raíz del repositorio.
ruta <- if (file.exists("datos/censo_departamentos.csv")) {
  "datos/censo_departamentos.csv"
} else {
  "../datos/censo_departamentos.csv"
}
censo <- read.csv(ruta, encoding = "UTF-8")

# --- 1) INTERFAZ DE USUARIO (UI) --------------------------------------------
ui <- fluidPage(
  titlePanel("Mi primera app Shiny"),

  # Un texto de bienvenida (contenido estático, escrito directo en la UI).
  p("Esta es la app más simple posible: un título, un texto y una tabla."),
  p("Los datos son del Censo 2023 de Uruguay (INE)."),

  # Un espacio (output) que será rellenado por el server:
  h3("Población por departamento"),
  tableOutput("tabla_censo"),

  # Otro output de texto dinámico:
  textOutput("resumen")
)

# --- 2) LÓGICA DEL SERVIDOR (server) ----------------------------------------
# El server "rellena" los outputs que definimos en la UI.
server <- function(input, output, session) {

  # Rellenamos el output "tabla_censo" con render*().
  output$tabla_censo <- renderTable({
    censo[, c("departamento", "poblacion_2023")]
  })

  # Rellenamos el output "resumen" con un texto calculado.
  output$resumen <- renderText({
    total <- sum(censo$poblacion_2023)
    paste0("Población total del país (Censo 2023): ",
           format(total, big.mark = "."), " habitantes.")
  })
}

# --- 3) ARRANCAR LA APP -----------------------------------------------------
shinyApp(ui = ui, server = server)
