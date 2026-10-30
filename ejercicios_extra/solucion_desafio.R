# =============================================================================
# SOLUCIÓN EJERCICIO EXTRA - Desafío

## PASO 0 · Ruta a los datos
# "../datos/" si este archivo está en ejercicios_extra/ del curso. Si no, la
# ruta a tu carpeta datos, con barras / y una barra al final.

RUTA_DATOS <- "../datos/"

library(shiny)
library(bslib)

# Personalizar A, cualquier título y colores sirven
TITULO          <- "¿Dónde vota la gente que vive en cada departamento?"
COLOR_PRINCIPAL <- "#E76F51"
COLOR_FONDO     <- "#FFFBF5"
COLOR_TEXTO     <- "#264653"
COLOR_BARRAS    <- "#2A9D8F"
REGION_INICIAL  <- "Centro"

tema <- bs_theme(version = 5, bg = COLOR_FONDO, fg = COLOR_TEXTO,
                 primary = COLOR_PRINCIPAL)

################################################################################

elecciones <- read.csv(paste0(RUTA_DATOS, "elecciones_departamento_2024.csv"), encoding = "UTF-8")
censo <- read.csv(paste0(RUTA_DATOS, "censo_departamentos.csv"), encoding = "UTF-8")   # Error 1, faltaba la s
censo <- censo[, c("departamento", "poblacion_2023")]

datos <- merge(elecciones, censo, by = "departamento")   # Error 2, va en minúscula
datos$hab_cada_100 <- round(datos$habilitados / datos$poblacion_2023 * 100, 1)   # Error 3, * 100

regiones <- sort(unique(datos$region))
total_pais <- sum(datos$habilitados) / sum(datos$poblacion_2023) * 100

################################################################################

ui <- fluidPage(
  theme = tema,
  titlePanel(TITULO),
  p("Personas habilitadas para votar (Elección Nacional 2024, Corte Electoral)
    y población (Censo 2023, INE), por departamento."),
  selectInput("region", "Elegí una región:", choices = regiones,
              selected = REGION_INICIAL),
  textOutput("resumen"),
  h3("Habilitados cada 100 habitantes"),   # Error 4, faltaba la coma
  plotOutput("grafico"),
  h3("Los números"),
  tableOutput("tabla")
)

################################################################################

server <- function(input, output, session) {

  # Personalizar B
  output$grafico <- renderPlot({
    datos_region <- datos[datos$region == input$region, ]
    datos_region <- datos_region[order(-datos_region$hab_cada_100), ]
    barplot(datos_region$hab_cada_100, names.arg = datos_region$departamento,
            col = COLOR_BARRAS, ylim = c(0, 100), las = 2)
    abline(h = total_pais, lty = 2)
  })

  output$tabla <- renderTable({
    datos_region <- datos[datos$region == input$region, ]   # Error 5, == en vez de =
    # Personalizar C
    tabla <- datos_region[, c("departamento", "habilitados", "poblacion_2023",
                              "hab_cada_100", "participacion_pct")]
    names(tabla) <- c("Departamento", "Habilitados", "Población 2023",
                      "Habilitados cada 100", "Participación (%)")
    tabla
  }, digits = 1)

  output$resumen <- renderText({   # Error 6, el id es resumen, como en la UI
    datos_region <- datos[datos$region == input$region, ]
    fila_max <- datos_region[which.max(datos_region$hab_cada_100), ]
    fila_min <- datos_region[which.min(datos_region$hab_cada_100), ]   # Personalizar D
    paste0("En la región ", input$region, ", el departamento con más habilitados ",
           "cada 100 habitantes es ", fila_max$departamento, " (", fila_max$hab_cada_100,
           ") y el que tiene menos es ", fila_min$departamento, " (",
           fila_min$hab_cada_100, ").")
  })
}

################################################################################

shinyApp(ui, server)
