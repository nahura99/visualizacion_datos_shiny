# =============================================================================
# CLASE 2 — Interfaz de Usuario (UI)
# Curso: Visualización interactiva de datos con R y Shiny (Udelar)
# -----------------------------------------------------------------------------
# Objetivo de la clase:
#   - Diseñar la interfaz visual: layouts, paneles y organización.
#   - Usar títulos, textos y etiquetas para guiar al usuario.
#   - sidebarLayout(): el patrón clásico "barra lateral + panel principal".
#
# En esta clase NO hay reactividad todavía: solo maquetamos la interfaz.
# =============================================================================

library(shiny)

ruta <- if (file.exists("datos/censo_departamentos.csv")) {
  "datos/censo_departamentos.csv"
} else {
  "../datos/censo_departamentos.csv"
}
censo <- read.csv(ruta, encoding = "UTF-8")

ui <- fluidPage(

  # Título principal de la app.
  titlePanel("Tablero del Censo 2023 — Uruguay"),

  # Layout de dos zonas: barra lateral (izquierda) y panel principal (derecha).
  sidebarLayout(

    # ----- Barra lateral: normalmente va acá lo que "controla" la app --------
    sidebarPanel(
      h4("Acerca del tablero"),
      p("Este tablero muestra datos de población por departamento",
        "según el Censo 2023 del INE."),
      tags$hr(),  # una línea divisoria
      p(tags$strong("Fuente:"), "Instituto Nacional de Estadística (INE)."),
      p(tags$em("En la próxima clase agregamos los controles interactivos."))
    ),

    # ----- Panel principal: normalmente van acá los resultados ---------------
    mainPanel(
      h3("¿Qué es Uruguay en números?"),
      p("El país tiene 19 departamentos. La tabla muestra la población",
        "de cada uno y su variación respecto al Censo 2011."),

      # Organizamos el contenido en pestañas (tabsetPanel):
      tabsetPanel(
        tabPanel("Tabla",
                 br(),
                 tableOutput("tabla")
        ),
        tabPanel("Resumen",
                 br(),
                 h4("Datos generales"),
                 tableOutput("resumen")
        )
      )
    )
  )
)

server <- function(input, output, session) {

  # Todavía sin interacción: mostramos la tabla completa.
  output$tabla <- renderTable({
    censo[, c("departamento", "region", "poblacion_2023", "variacion_pct")]
  })

  output$resumen <- renderTable({
    data.frame(
      Indicador = c("Departamentos", "Población total 2023", "Población total 2011"),
      Valor = c(
        nrow(censo),
        format(sum(censo$poblacion_2023), big.mark = "."),
        format(sum(censo$poblacion_2011), big.mark = ".")
      )
    )
  })
}

shinyApp(ui = ui, server = server)
