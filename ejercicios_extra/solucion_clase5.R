# =============================================================================
# SOLUCIÓN · EJERCICIO EXTRA 5 · Calcular una sola vez
# =============================================================================

library(shiny)
library(bslib)

################################################################################
## ZONA DE PRUEBAS
TITULO <- "Participación electoral 2024"

COLOR_PRINCIPAL <- "#5A189A"
COLOR_FONDO     <- "#FFFFFF"
COLOR_TEXTO     <- "#2E0A4E"

################################################################################

tema <- bs_theme(version = 5, bg = COLOR_FONDO, fg = COLOR_TEXTO,
                 primary = COLOR_PRINCIPAL)

# CODIGO ESTATICO
elecciones <- read.csv("../datos/elecciones_departamento_2024.csv", encoding = "UTF-8")
regiones   <- sort(unique(elecciones$region))


################################################################################
# INTERFAZ (UI)

barra <- sidebarPanel(
  selectInput("region", "Región:",
              choices = regiones, selected = regiones, multiple = TRUE),
  sliderInput("blanco", "Voto en blanco máximo (%):",
              min = 1, max = 2, value = 2, step = 0.1),

  # CONSIGNA 3
  actionButton("actualizar", "Actualizar", class = "btn-primary")
)

ui <- fluidPage(
  theme = tema,
  titlePanel(TITULO),
  sidebarLayout(
    barra,
    mainPanel(
      h4(textOutput("n_deptos")),
      plotOutput("grafico", height = "450px"),
      tableOutput("tabla")
    )
  )
)


################################################################################
# SERVIDOR (SERVER)

server <- function(input, output, session) {

  # CONSIGNA 1 y 2. El filtro una sola vez, con req() antes y después.
  filtrados <- reactive({
    req(input$region)   # sin regiones, espera
    d <- elecciones[elecciones$region %in% input$region &
                    elecciones$en_blanco_pct <= input$blanco, ]
    req(nrow(d) > 0)    # si el filtro deja la tabla vacía, también espera
    d
  })

  # CONSIGNA 3. datos() se actualiza solo con el botón.
  # Si no hacés la consigna 3, alcanza con llamar datos al reactive de arriba.
  datos <- eventReactive(input$actualizar, {
    filtrados()
  }, ignoreNULL = FALSE)

  output$n_deptos <- renderText({
    paste(nrow(datos()), "departamentos")
  })

  output$grafico <- renderPlot({
    d <- datos()
    d <- d[order(d$participacion_pct), ]
    par(mar = c(4, 9, 2, 1))
    barplot(d$participacion_pct, names.arg = d$departamento, horiz = TRUE,
            las = 1, col = COLOR_PRINCIPAL, border = NA, cex.names = 0.8,
            xlim = c(0, 100), main = "Participación (%)")
  })

  output$tabla <- renderTable({
    d <- datos()
    d[order(-d$participacion_pct),
      c("departamento", "region", "participacion_pct", "en_blanco_pct", "anulados_pct")]
  })
}


################################################################################
shinyApp(ui = ui, server = server)
