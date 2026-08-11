# =============================================================================
# CLASE 4 — Salidas (Outputs)
# Curso: Visualización interactiva de datos con R y Shiny (Udelar)
# -----------------------------------------------------------------------------
# Objetivo de la clase:
#   - Generar resultados que se actualizan según los inputs.
#   - Cada output vive en dos lugares:
#       * en la UI:     algo*Output("id")   -> reserva el espacio
#       * en el server: output$id <- render*({...}) -> lo rellena
#   - Pares típicos:
#       textOutput()  <-> renderText()
#       tableOutput() <-> renderTable()
#
# Acá los controles YA filtran la tabla. Aún no usamos reactive() (Clase 5).
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
  titlePanel("Clase 4 — Salidas que responden a los controles"),

  sidebarLayout(
    sidebarPanel(
      selectInput("region", "Región:",
                  choices = regiones, selected = regiones, multiple = TRUE),
      sliderInput("min_pob", "Población mínima (2023):",
                  min = 0, max = max(censo$poblacion_2023),
                  value = 0, step = 10000)
    ),

    mainPanel(
      # Tres outputs: dos "cajas" de texto y una tabla.
      fluidRow(
        column(6, h4("Departamentos mostrados"), textOutput("n_deptos")),
        column(6, h4("Población seleccionada"),  textOutput("pob_total"))
      ),
      tags$hr(),
      h4("Detalle por departamento"),
      tableOutput("tabla")
    )
  )
)

server <- function(input, output, session) {

  # OJO: repetimos el filtro en cada output. Funciona, pero es repetitivo.
  # En la Clase 5 lo resolvemos con reactive().

  output$n_deptos <- renderText({
    d <- censo[censo$region %in% input$region &
                 censo$poblacion_2023 >= input$min_pob, ]
    paste0(nrow(d), " de ", nrow(censo))
  })

  output$pob_total <- renderText({
    d <- censo[censo$region %in% input$region &
                 censo$poblacion_2023 >= input$min_pob, ]
    format(sum(d$poblacion_2023), big.mark = ".")
  })

  output$tabla <- renderTable({
    d <- censo[censo$region %in% input$region &
                 censo$poblacion_2023 >= input$min_pob, ]
    d[order(-d$poblacion_2023),
      c("departamento", "region", "poblacion_2023", "variacion_pct")]
  })
}

shinyApp(ui = ui, server = server)
