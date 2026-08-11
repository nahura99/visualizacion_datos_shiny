# =============================================================================
# CLASE 3 — Entradas de Datos (Inputs)
# Curso: Visualización interactiva de datos con R y Shiny (Udelar)
# -----------------------------------------------------------------------------
# Objetivo de la clase:
#   - Conocer los controles de entrada (inputs) más usados.
#   - Entender que cada input tiene un id (para leerlo con input$id).
#   - Ver el valor de los inputs "en vivo" (todavía sin filtrar datos).
#
# Inputs que usamos:
#   selectInput()      -> menú desplegable
#   sliderInput()      -> deslizador numérico / rango
#   checkboxGroupInput() -> selección múltiple
#   textInput()        -> caja de texto
# =============================================================================

library(shiny)

ruta <- if (file.exists("datos/censo_departamentos.csv")) {
  "datos/censo_departamentos.csv"
} else {
  "../datos/censo_departamentos.csv"
}
censo <- read.csv(ruta, encoding = "UTF-8")

# Opciones que ofreceremos en los menús (se calculan una vez, al inicio):
regiones     <- sort(unique(censo$region))
poblacion_max <- max(censo$poblacion_2023)

ui <- fluidPage(
  titlePanel("Clase 3 — Controles interactivos (Inputs)"),

  sidebarLayout(
    sidebarPanel(
      h4("Probá los controles"),

      # Menú desplegable de selección múltiple:
      selectInput(
        inputId  = "region",
        label    = "Región:",
        choices  = regiones,
        selected = regiones,
        multiple = TRUE
      ),

      # Deslizador de rango de población:
      sliderInput(
        inputId = "rango_pob",
        label   = "Rango de población (2023):",
        min     = 0,
        max     = poblacion_max,
        value   = c(0, poblacion_max),
        step    = 10000
      ),

      # Casillas para elegir qué columnas mirar:
      checkboxGroupInput(
        inputId  = "columnas",
        label    = "Columnas a mostrar:",
        choices  = c("Población 2011" = "poblacion_2011",
                     "Población 2023" = "poblacion_2023",
                     "Variación %"    = "variacion_pct",
                     "Densidad"       = "densidad_2023"),
        selected = c("poblacion_2023", "variacion_pct")
      ),

      # Caja de texto libre:
      textInput(
        inputId = "titulo",
        label   = "Ponele un título a tu tablero:",
        value   = "Mi tablero del Censo"
      )
    ),

    mainPanel(
      # Mostramos EL VALOR de cada input para entender qué devuelven.
      # (Todavía no filtramos datos: eso es la próxima clase.)
      h3(textOutput("titulo_dinamico")),
      tags$hr(),
      h4("Valores actuales de los controles:"),
      verbatimTextOutput("valores")
    )
  )
)

server <- function(input, output, session) {

  # input$titulo se actualiza solo cuando el usuario escribe.
  output$titulo_dinamico <- renderText({
    input$titulo
  })

  # Leemos varios inputs y mostramos qué contienen.
  output$valores <- renderText({
    paste0(
      "Regiones elegidas: ", paste(input$region, collapse = ", "), "\n",
      "Rango de población: ", input$rango_pob[1], " a ", input$rango_pob[2], "\n",
      "Columnas: ", paste(input$columnas, collapse = ", ")
    )
  })
}

shinyApp(ui = ui, server = server)
