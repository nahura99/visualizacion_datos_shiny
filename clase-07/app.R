# =============================================================================
# CLASE 7 · Gráficos Dinámicos
# Curso: Visualización interactiva de datos con R y Shiny (Udelar)
# -----------------------------------------------------------------------------
# Objetivo de la clase
#   - Integrar gráficos de ggplot2 que se actualizan según los filtros.
#   - Elegir la variable a graficar desde un input (.data[[input$var]]).
#   - Interactuar CON el gráfico: clic en un punto (nearPoints()).
#   - Pasar de ggplot2 a un gráfico web con plotly (ggplotly()).
#   - Descargar el gráfico como imagen.
#
# Componentes que se explican en clase
#   plotOutput() / renderPlot()     -> gráfico estático (ggplot2)
#   aes(.data[[input$var]])         -> mapear una columna elegida por el usuario
#   plotOutput(click = "id")        -> el gráfico también es un input
#   nearPoints()                    -> filas cercanas al clic
#   plotlyOutput() / renderPlotly() -> gráfico interactivo (zoom, hover)
#   downloadHandler() + ggsave()    -> descargar el gráfico
# =============================================================================

library(shiny)
library(bslib)
library(ggplot2)
library(plotly)

# --- Estética del curso (se explica en la Clase 8) ---------------------------
VIOLETA_PROFUNDO <- "#2E0A4E"; VIOLETA <- "#5A189A"
VIOLETA_CLARO    <- "#9D4EDD"; ACENTO  <- "#C77DFF"
tema_curso <- bs_theme(
  version = 5, bg = "#FFFFFF", fg = VIOLETA_PROFUNDO,
  primary = VIOLETA, secondary = VIOLETA_CLARO,
  base_font    = font_google("Inter",  local = FALSE),
  heading_font = font_google("Oswald", local = FALSE)
)
# Paleta para las cinco regiones (derivada de la paleta del curso).
COLORES_REGION <- c(Metropolitana = "#2E0A4E", Litoral = "#5A189A",
                    Norte = "#7B2CBF", Centro = "#9D4EDD", Este = "#C77DFF")

# Un tema de ggplot2 para que todos los gráficos se vean iguales.
tema_ggplot <- theme_minimal(base_size = 14) +
  theme(plot.title = element_text(face = "bold", colour = VIOLETA_PROFUNDO),
        legend.position = "bottom")

# --- Datos (código estático) -------------------------------------------------
buscar <- function(archivo) {
  if (file.exists(file.path("datos", archivo))) file.path("datos", archivo)
  else file.path("..", "datos", archivo)
}
elecciones <- read.csv(buscar("elecciones_departamento_2024.csv"), encoding = "UTF-8")
# Segundo dataset: una fila por local de votación (2.521 locales). Lo usamos
# para el histograma, donde 19 departamentos son pocos puntos.
locales <- read.csv(buscar("elecciones_locales_2024.csv"), encoding = "UTF-8")

regiones  <- sort(unique(elecciones$region))
VARIABLES <- c("Participación (%)"       = "participacion_pct",
               "Margen del ganador (pp)" = "margen_pct",
               "Personas habilitadas"    = "habilitados",
               "% Frente Amplio"         = "pct_frente_amplio",
               "% Partido Nacional"      = "pct_partido_nacional",
               "% Partido Colorado"      = "pct_partido_colorado",
               "% SÍ Art. 11"            = "pct_si_art11",
               "% SÍ Art. 67"            = "pct_si_art67")
etiqueta_de <- function(v) names(VARIABLES)[VARIABLES == v]

# --- UI ----------------------------------------------------------------------
ui <- fluidPage(
  theme = tema_curso,
  titlePanel("Clase 7 · Gráficos que reaccionan a los filtros"),

  sidebarLayout(
    sidebarPanel(
      width = 3,
      selectInput("region", "Región:",
                  choices = regiones, selected = regiones, multiple = TRUE),
      selectInput("variable", "Variable (barras y eje Y):",
                  choices = VARIABLES, selected = "participacion_pct"),
      selectInput("variable_x", "Variable del eje X (dispersión):",
                  choices = VARIABLES, selected = "margen_pct"),
      checkboxInput("colorear", "Colorear por región", value = TRUE),
      sliderInput("bins", "Barras del histograma:", min = 10, max = 60, value = 30),
      hr(),
      downloadButton("descargar_grafico", "Descargar barras (.png)")
    ),

    mainPanel(
      width = 9,
      tabsetPanel(
        tabPanel("Barras", br(),
                 plotOutput("g_barras", height = "480px")),

        tabPanel("Dispersión", br(),
                 p("Hacé clic sobre un punto para identificar el departamento."),
                 # click = "...": el gráfico avisa dónde se hizo clic.
                 plotOutput("g_puntos", height = "420px", click = "clic_punto"),
                 tableOutput("punto_elegido")),

        tabPanel("Histograma", br(),
                 p("Distribución de la participación en los",
                   strong("locales de votación"), "de las regiones elegidas."),
                 plotOutput("g_hist", height = "420px")),

        tabPanel("Interactivo (plotly)", br(),
                 p("El mismo gráfico de dispersión, pero con zoom, hover y",
                   "leyenda clicable. Basta envolver el ggplot con ggplotly()."),
                 plotlyOutput("g_plotly", height = "460px"))
      )
    )
  )
)

# --- SERVER ------------------------------------------------------------------
server <- function(input, output, session) {

  datos_filtrados <- reactive({
    req(input$region)
    elecciones[elecciones$region %in% input$region, ]
  })

  locales_filtrados <- reactive({
    req(input$region)
    deptos <- elecciones$departamento[elecciones$region %in% input$region]
    l <- locales[locales$DepartamentoNombre %in% deptos, ]
    l[!is.na(l$PctParticipacionPropios) & l$TotalHabilitados >= 100, ]
  })

  # ----- 1) Barras: el gráfico como función, para reusarlo en la descarga ----
  grafico_barras <- reactive({
    d <- datos_filtrados()
    g <- ggplot(d, aes(x = reorder(departamento, .data[[input$variable]]),
                       y = .data[[input$variable]]))
    if (input$colorear) {
      g <- g + geom_col(aes(fill = region)) +
        scale_fill_manual(values = COLORES_REGION, name = NULL)
    } else {
      g <- g + geom_col(fill = VIOLETA)
    }
    g + coord_flip() +
      labs(x = NULL, y = etiqueta_de(input$variable),
           title = paste(etiqueta_de(input$variable), "por departamento")) +
      tema_ggplot
  })
  output$g_barras <- renderPlot(grafico_barras(), res = 96)

  # ----- 2) Dispersión con clic ------------------------------------------------
  grafico_puntos <- reactive({
    d <- datos_filtrados()
    ggplot(d, aes(x = .data[[input$variable_x]], y = .data[[input$variable]],
                  colour = region, text = departamento)) +
      geom_point(size = 4, alpha = 0.9) +
      scale_colour_manual(values = COLORES_REGION, name = NULL) +
      scale_x_continuous(labels = scales::comma) +
      scale_y_continuous(labels = scales::comma) +
      labs(x = etiqueta_de(input$variable_x), y = etiqueta_de(input$variable),
           title = "Un punto por departamento") +
      tema_ggplot
  })
  output$g_puntos <- renderPlot(grafico_puntos(), res = 96)

  # nearPoints() busca, en los datos, las filas cercanas al clic.
  output$punto_elegido <- renderTable({
    req(input$clic_punto)
    nearPoints(datos_filtrados(), input$clic_punto,
               xvar = input$variable_x, yvar = input$variable,
               threshold = 15, maxpoints = 1)[
      , c("departamento", "region", "lema_ganador", "pct_ganador", "margen_pct")]
  })

  # ----- 3) Histograma a nivel de local de votación -------------------------
  output$g_hist <- renderPlot({
    l <- locales_filtrados()
    ggplot(l, aes(x = PctParticipacionPropios)) +
      geom_histogram(bins = input$bins, fill = VIOLETA_CLARO, colour = "white") +
      geom_vline(xintercept = median(l$PctParticipacionPropios),
                 colour = VIOLETA_PROFUNDO, linetype = "dashed") +
      labs(x = "Participación en el local (%)", y = "Cantidad de locales",
           title = paste0(format(nrow(l), big.mark = "."),
                          " locales de votación · la línea marca la mediana")) +
      tema_ggplot
  }, res = 96)

  # ----- 4) plotly: el mismo ggplot, interactivo -----------------------------
  output$g_plotly <- renderPlotly({
    ggplotly(grafico_puntos(), tooltip = c("text", "x", "y"))
  })

  # ----- Descarga del gráfico de barras --------------------------------------
  output$descargar_grafico <- downloadHandler(
    filename = function() paste0("barras_", input$variable, ".png"),
    content  = function(archivo) {
      ggsave(archivo, grafico_barras(), width = 9, height = 6, dpi = 150, bg = "white")
    }
  )
}

shinyApp(ui = ui, server = server)
