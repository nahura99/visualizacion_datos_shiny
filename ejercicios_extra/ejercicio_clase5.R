# =============================================================================
# EJERCICIO EXTRA 5 · Calcular una sola vez
# La app funciona pero repite el mismo filtro en cada output y se rompe si
# no hay región elegida. Hay que ordenarla con reactive(), req() y un botón.
# =============================================================================

################################################################################
## PASO 0 · LA RUTA A LOS DATOS
# La app lee las tablas de la carpeta datos/. Antes de empezar, revisá que la
# ruta de abajo lleve a esa carpeta.
#
# Run App trabaja desde la carpeta donde está guardado ESTE archivo.
#   - Si está en ejercicios_extra/, dentro de la carpeta del curso, datos/
#     queda un nivel más arriba. Por eso la ruta empieza con "../"
#   - Si lo guardaste en otro lado, poné la ruta a tu carpeta datos, con
#     barras / y una barra al final. Por ejemplo
#     "C:/Users/tu_usuario/Documents/curso_shiny/datos/"
# Si la ruta está mal, al apretar Run App aparece un error que dice
# "cannot open file" o "No such file or directory".
RUTA_DATOS <- "../datos/"

# Para después de la Clase 5.
# Antes de tocar nada, corré la app y borrá todas las regiones del menú.
# Mirá qué pasa con el gráfico.

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
# paste0() pega la ruta del PASO 0 con el nombre del archivo.
elecciones <- read.csv(paste0(RUTA_DATOS, "elecciones_departamento_2024.csv"), encoding = "UTF-8")
regiones   <- sort(unique(elecciones$region))


################################################################################
# INTERFAZ (UI)

barra <- sidebarPanel(
  selectInput("region", "Región:",
              choices = regiones, selected = regiones, multiple = TRUE),
  sliderInput("blanco", "Voto en blanco máximo (%):",
              min = 1, max = 2, value = 2, step = 0.1)

  # CONSIGNA 3 (botón). Va acá.
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

  # CONSIGNA 1
  # El filtro (las dos líneas que arman d) está escrito tres veces, una en
  # cada output. Escribilo UNA sola vez con reactive(), guardalo en un objeto
  # que se llame datos, y hacé que los tres outputs lo usen.
  # OJO, a un reactive se lo llama con paréntesis, datos(). Si te olvidás de
  # los paréntesis, Shiny da un error bastante raro.

  # CONSIGNA 2
  # Cuando no hay ninguna región elegida, el gráfico muestra un error en rojo.
  # Arreglalo para que la app espere sin mostrar errores. Va adentro del
  # reactive, antes del filtro.

  # CONSIGNA 3
  # Que los resultados cambien solo cuando se aprieta un botón "Actualizar",
  # y no cada vez que se mueve un filtro. Hace falta un actionButton() en la
  # barra y un eventReactive() acá. Acordate de ignoreNULL = FALSE, si no
  # la app arranca vacía hasta el primer clic.

  output$n_deptos <- renderText({
    d <- elecciones[elecciones$region %in% input$region &
                    elecciones$en_blanco_pct <= input$blanco, ]
    paste(nrow(d), "departamentos")
  })

  output$grafico <- renderPlot({
    d <- elecciones[elecciones$region %in% input$region &
                    elecciones$en_blanco_pct <= input$blanco, ]
    d <- d[order(d$participacion_pct), ]
    par(mar = c(4, 9, 2, 1))
    barplot(d$participacion_pct, names.arg = d$departamento, horiz = TRUE,
            las = 1, col = COLOR_PRINCIPAL, border = NA, cex.names = 0.8,
            xlim = c(0, 100), main = "Participación (%)")
  })

  output$tabla <- renderTable({
    d <- elecciones[elecciones$region %in% input$region &
                    elecciones$en_blanco_pct <= input$blanco, ]
    d[order(-d$participacion_pct),
      c("departamento", "region", "participacion_pct", "en_blanco_pct", "anulados_pct")]
  })
}


################################################################################
shinyApp(ui = ui, server = server)
