# =============================================================================
# SOLUCIÓN · EJERCICIO EXTRA 3 · Ordenar la pantalla
# =============================================================================

## PASO 0 · Ruta a los datos
# "../datos/" si este archivo está en ejercicios_extra/ del curso. Si no, la
# ruta a tu carpeta datos, con barras / y una barra al final.
RUTA_DATOS <- "../datos/"

library(shiny)
library(bslib)

TITULO <- "Elección Nacional 2024"
tema   <- bs_theme(version = 5, bg = "#FFFFFF", fg = "#2E0A4E", primary = "#5A189A")

elecciones <- read.csv(paste0(RUTA_DATOS, "elecciones_departamento_2024.csv"), encoding = "UTF-8")
regiones   <- sort(unique(elecciones$region))

barra <- sidebarPanel(
  selectInput("region", "Región:", choices = regiones, selected = regiones, multiple = TRUE),
  hr(), h5("Fuente"),   # Consigna 3
  p(a("Corte Electoral", href = "https://www.corteelectoral.gub.uy", target = "_blank"))
)

# Consigna 1, tres columnas de 4 (suman 12)
numeros <- fluidRow(
  column(4, h5("Departamentos"),          h2(textOutput("n_deptos"), class = "text-primary")),
  column(4, h5("Emitidos"),               h2(textOutput("emitidos"), class = "text-primary")),
  column(4, h5("Votos al Frente Amplio"), h2(textOutput("votos_fa"), class = "text-primary"))
)

# Consigna 2
pestanas <- tabsetPanel(type = "pills",
  tabPanel("Tabla", br(), tableOutput("tabla")),
  tabPanel("Ayuda", br(),
           p(strong("emitidos"), "son los votos depositados en las urnas."),
           p(strong("pct_frente_amplio"), "es el porcentaje del FA sobre los votos a lemas."),
           p(strong("region"), "agrupa los departamentos como en el curso."))
)

ui <- fluidPage(
  theme = tema,
  titlePanel(TITULO),
  sidebarLayout(position = "right",   # Extra, barra a la derecha
                barra, mainPanel(numeros, hr(), pestanas))
)

server <- function(input, output, session) {
  output$n_deptos <- renderText({
    d <- elecciones[elecciones$region %in% input$region, ]
    nrow(d)
  })
  output$emitidos <- renderText({
    d <- elecciones[elecciones$region %in% input$region, ]
    format(sum(d$emitidos), big.mark = ".", decimal.mark = ",")
  })
  output$votos_fa <- renderText({
    d <- elecciones[elecciones$region %in% input$region, ]
    format(sum(d$votos_frente_amplio), big.mark = ".", decimal.mark = ",")
  })
  output$tabla <- renderTable({
    d <- elecciones[elecciones$region %in% input$region, ]
    d[order(-d$emitidos), c("departamento", "region", "emitidos", "pct_frente_amplio")]
  })
}

shinyApp(ui, server)
