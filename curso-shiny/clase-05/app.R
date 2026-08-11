# =============================================================================
# CLASE 5 — El Motor Reactivo
# Curso: Visualización interactiva de datos con R y Shiny (Udelar)
# -----------------------------------------------------------------------------
# Objetivo de la clase:
#   - Entender cómo Shiny "escucha" los inputs y recalcula SOLO lo necesario.
#   - reactive(): crea un valor reactivo que se calcula una vez y se reutiliza.
#   - req(): frena el cálculo si falta algo (evita errores feos).
#   - Buenas prácticas para no repetir código (comparar con la Clase 4).
#
# Idea central: en vez de filtrar los datos en cada output, filtramos UNA vez
# dentro de un reactive() y todos los outputs lo reutilizan. Cuando un input
# cambia, Shiny recalcula el reactive y actualiza solo los outputs que lo usan.
# =============================================================================

library(shiny)

ruta <- if (file.exists("datos/censo_departamentos.csv")) {
  "datos/censo_departamentos.csv"
} else {
  "../datos/censo_departamentos.csv"
}
censo <- read.csv(ruta, encoding = "UTF-8")

regiones <- sort(unique(censo$region))

ui <- fluidPage(
  titlePanel("Clase 5 — Reactividad: calcular una vez, usar muchas"),

  sidebarLayout(
    sidebarPanel(
      selectInput("region", "Región:",
                  choices = regiones, selected = regiones, multiple = TRUE),
      sliderInput("min_pob", "Población mínima (2023):",
                  min = 0, max = max(censo$poblacion_2023),
                  value = 0, step = 10000),
      helpText("Si deseleccionás todas las regiones, la app te avisa",
               "en vez de romperse (gracias a req()).")
    ),

    mainPanel(
      fluidRow(
        column(6, h4("Departamentos"), textOutput("n_deptos")),
        column(6, h4("Población"),     textOutput("pob_total"))
      ),
      tags$hr(),
      tableOutput("tabla")
    )
  )
)

server <- function(input, output, session) {

  # ----- UN solo reactive con los datos filtrados --------------------------
  datos_filtrados <- reactive({
    # req() detiene el cálculo (sin error) si no hay ninguna región elegida.
    req(input$region)

    censo[censo$region %in% input$region &
            censo$poblacion_2023 >= input$min_pob, ]
  })

  # ----- Todos los outputs REUTILIZAN datos_filtrados() --------------------
  output$n_deptos <- renderText({
    paste0(nrow(datos_filtrados()), " de ", nrow(censo))
  })

  output$pob_total <- renderText({
    format(sum(datos_filtrados()$poblacion_2023), big.mark = ".")
  })

  output$tabla <- renderTable({
    d <- datos_filtrados()
    d[order(-d$poblacion_2023),
      c("departamento", "region", "poblacion_2023", "variacion_pct")]
  })
}

shinyApp(ui = ui, server = server)
