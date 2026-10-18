# =============================================================================
# SOLUCIÓN EJERCICIO EXTRA 2 

## PASO 0 · Ruta a los datos
# "../datos/" si este archivo está en ejercicios_extra/ del curso. Si no, la
# ruta a tu carpeta datos, con barras / y una barra al final.

RUTA_DATOS <- "../datos/"

library(shiny)
library(bslib)

TITULO <- "El censo por departamento"
LAYOUT <- "lateral"   # Consigna 3, cualquiera de las tres sirve
tema   <- bs_theme(version = 5, bg = "#FFFFFF", fg = "#2E0A4E", primary = "#5A189A")


################################################################################

censo <- read.csv(paste0(RUTA_DATOS, "censo_departamentos.csv"), encoding = "UTF-8")
departamentos <- sort(censo$departamento)   # Consigna 1

################################################################################

controles  <- selectInput("depto", "Elegí un departamento:",
                          choices = departamentos, selected = "Montevideo")
resultados <- tagList(h3("Ficha del departamento"), textOutput("ficha"),
                      h3("Todos los departamentos"), tableOutput("tabla"))

################################################################################

cuerpo <- switch(LAYOUT,
  simple   = tagList(controles, resultados),
  lateral  = sidebarLayout(sidebarPanel(controles), mainPanel(resultados)),
  columnas = fluidRow(column(6, controles), column(6, resultados))
)

ui <- fluidPage(theme = tema, titlePanel(TITULO),
                p("Datos de los Censos 2011 y 2023 (INE)."), cuerpo)

server <- function(input, output, session) {
  # Consigna 2, un pedazo más en el paste0()
  output$ficha <- renderText({
    fila <- censo[censo$departamento == input$depto, ]
    paste0("En ", fila$departamento, " viven ",
           format(fila$poblacion_2023, big.mark = ".", decimal.mark = ","),
           " personas. Desde 2011 la población cambió un ", fila$variacion_pct, "%.")
  })
  
  # Extra... queda ordenada por densidad (Montevideo queda primero)
  output$tabla <- renderTable({
    censo[order(-censo$densidad_2023),
          c("departamento", "region", "poblacion_2023", "variacion_pct", "densidad_2023")]
  })
}

shinyApp(ui, server)
