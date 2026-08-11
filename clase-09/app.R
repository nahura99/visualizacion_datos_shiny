# =============================================================================
# CLASE 9 — Trabajo Final (I): PLANTILLA para tu propia Shiny
# Curso: Visualización interactiva de datos con R y Shiny (Udelar)
# -----------------------------------------------------------------------------
# Objetivo de la clase:
#   - Arrancar TU trabajo final: una Shiny sobre un tema que te interese
#     (datos electorales de la Corte Electoral, datos del MIDES, datos abiertos
#     del Estado, encuestas, tu propia investigación, etc.).
#   - Esta plantilla ya tiene la estructura completa: solo tenés que reemplazar
#     los bloques marcados con  # TODO  por tus datos y tus gráficos.
#
# Pasos sugeridos:
#   1) Poné tu archivo de datos en la carpeta datos/ (por ejemplo mis_datos.csv).
#   2) Reemplazá los TODO de abajo.
#   3) Corré la app con el botón "Run App" de RStudio.
# =============================================================================

library(shiny)
library(bslib)
library(ggplot2)

# --- 1) TUS DATOS -----------------------------------------------------------
# TODO: cambiá el nombre del archivo por el tuyo.
ruta <- "datos/mis_datos.csv"
if (!file.exists(ruta)) {
  # Mientras no cargues tus datos, usamos el Censo como ejemplo para que
  # la plantilla corra igual.
  ruta <- if (file.exists("../datos/censo_departamentos.csv"))
    "../datos/censo_departamentos.csv" else "datos/censo_departamentos.csv"
}
datos <- read.csv(ruta, encoding = "UTF-8")

# TODO: definí cuál columna es la CATEGORÍA (para filtrar) y cuál la NUMÉRICA.
col_categoria <- names(datos)[1]                       # ej: "departamento"
cols_numericas <- names(datos)[sapply(datos, is.numeric)]

# --- Estética del curso -----------------------------------------------------
morado <- "#5A189A"; morado_profundo <- "#2E0A4E"
tema <- bs_theme(version = 5, bg = "#FFFFFF", fg = morado_profundo,
                 primary = morado, base_font = font_google("Inter"),
                 heading_font = font_google("Oswald"))

# --- 2) INTERFAZ ------------------------------------------------------------
ui <- page_navbar(
  title = "Mi trabajo final",   # TODO: poné el título de tu proyecto
  theme = tema,

  sidebar = sidebar(
    title = "Filtros",
    # TODO: ajustá los filtros a tus datos.
    selectInput("categoria", "Filtrar por:",
                choices = unique(datos[[col_categoria]]),
                selected = unique(datos[[col_categoria]]),
                multiple = TRUE),
    selectInput("y", "Variable a graficar:",
                choices = cols_numericas, selected = cols_numericas[1])
  ),

  nav_panel("Gráfico", card(card_header("Mi gráfico"), plotOutput("grafico"))),
  nav_panel("Tabla",   card(card_header("Mis datos"),  tableOutput("tabla"))),
  nav_panel("Acerca de",
            card(card_header("Sobre mi proyecto"),
                 p("TODO: describí tu tema, tu pregunta y tu fuente de datos."),
                 p(tags$strong("Fuente:"), "TODO (ej: Corte Electoral, MIDES, INE).")))
)

# --- 3) LÓGICA --------------------------------------------------------------
server <- function(input, output, session) {

  datos_filtrados <- reactive({
    req(input$categoria)
    datos[datos[[col_categoria]] %in% input$categoria, ]
  })

  output$grafico <- renderPlot({
    d <- datos_filtrados()
    # TODO: cambiá el tipo de gráfico si querés (geom_point, geom_line, etc.).
    ggplot(d, aes(x = reorder(.data[[col_categoria]], .data[[input$y]]),
                  y = .data[[input$y]])) +
      geom_col(fill = morado) +
      coord_flip() +
      labs(x = NULL, y = input$y) +
      theme_minimal(base_size = 14)
  })

  output$tabla <- renderTable({
    datos_filtrados()
  })
}

shinyApp(ui = ui, server = server)
