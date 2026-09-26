# =============================================================================
# CLASE 8 · Estética y Navegación
# Curso: Visualización interactiva de datos con R y Shiny (Udelar)
# -----------------------------------------------------------------------------
# Objetivo de la clase
#   - Entender (por fin) el bloque de "estética del curso" que venimos copiando:
#     bs_theme() y los temas de Bootstrap 5 con {bslib}.
#   - Organizar la navegación con page_navbar(), nav_panel() y sidebar().
#   - Jerarquizar la información con card(), value_box() y layout_columns().
#   - Mostrar controles distintos según la pestaña activa (conditionalPanel).
#   - Tablas interactivas con {DT}: ordenar, buscar, paginar, exportar.
#   - Modo oscuro, tooltips y CSS propio.
#
# Componentes que se explican en clase
#   bs_theme(), font_google(), bs_themer()
#   page_navbar(), nav_panel(), nav_spacer(), nav_item(), sidebar()
#   layout_columns(), card(), card_header(), card_footer(), value_box()
#   accordion(), tooltip(), input_dark_mode()
#   conditionalPanel()  -> mostrar u ocultar controles según una condición
#   DT::DTOutput() / DT::renderDT() / DT::datatable()
#   tags$style()        -> CSS propio
# =============================================================================

library(shiny)
library(bslib)
library(ggplot2)
library(DT)

# --- ESTÉTICA DEL CURSO (hoy sí la explicamos) ------------------------------
# Un tema de bslib es un conjunto de variables de Bootstrap: colores, fuentes,
# bordes. Cambiás una variable acá y cambia TODA la app.
VIOLETA_PROFUNDO <- "#2E0A4E"   # fondo de títulos, texto principal
VIOLETA          <- "#5A189A"   # color primario: botones, links, barra
VIOLETA_CLARO    <- "#9D4EDD"   # color secundario, gráficos
ACENTO           <- "#C77DFF"   # detalles, hover

tema_curso <- bs_theme(
  version      = 5,                 # Bootstrap 5
  bg           = "#FFFFFF",         # fondo
  fg           = VIOLETA_PROFUNDO,  # texto
  primary      = VIOLETA,           # "brand color"
  secondary    = VIOLETA_CLARO,
  base_font    = font_google("Inter",  local = FALSE),  # texto corrido
  heading_font = font_google("Oswald", local = FALSE),  # títulos
  "navbar-bg"  = VIOLETA_PROFUNDO,  # cualquier variable de Bootstrap, entre comillas
  "navbar-fg"  = "#FFFFFF"
)
# Tip: bs_themer() abre un panel para probar colores en vivo (solo en desarrollo).

# CSS propio: lo que el tema no cubre se ajusta con una hoja de estilo.
css_propio <- "
  .navbar-brand { font-family: 'Oswald', sans-serif; letter-spacing: .5px; }
  .card-header  { font-family: 'Oswald', sans-serif; font-size: 1.05rem; }
  .bslib-value-box .value-box-title { font-size: .85rem; opacity: .9; }
"

COLORES_REGION <- c(Metropolitana = "#2E0A4E", Litoral = "#5A189A",
                    Norte = "#7B2CBF", Centro = "#9D4EDD", Este = "#C77DFF")
tema_ggplot <- theme_minimal(base_size = 13) +
  theme(legend.position = "bottom")

# --- Datos (código estático) -------------------------------------------------
ruta <- if (file.exists("datos/elecciones_departamento_2024.csv")) {
  "datos/elecciones_departamento_2024.csv"
} else {
  "../datos/elecciones_departamento_2024.csv"
}
elecciones <- read.csv(ruta, encoding = "UTF-8")
regiones   <- sort(unique(elecciones$region))
VARIABLES  <- c("Participación (%)"       = "participacion_pct",
                "Margen del ganador (pp)" = "margen_pct",
                "Personas habilitadas"    = "habilitados",
                "% SÍ Art. 11"            = "pct_si_art11",
                "% SÍ Art. 67"            = "pct_si_art67")
etiqueta_de <- function(v) names(VARIABLES)[VARIABLES == v]

# Traducción de la tabla DT al español (se reutiliza en la Clase 9).
DT_ES <- list(
  lengthMenu = "Mostrar _MENU_ filas", search = "Buscar:",
  info = "Mostrando _START_ a _END_ de _TOTAL_ filas",
  infoEmpty = "Sin filas", zeroRecords = "No se encontraron resultados",
  paginate = list(first = "Primero", last = "Último",
                  `next` = "Siguiente", previous = "Anterior")
)

# --- UI ----------------------------------------------------------------------
# page_navbar(): una barra de navegación arriba y una pestaña por nav_panel().
ui <- page_navbar(
  title  = "Elecciones 2024 · Uruguay",
  id     = "pestana",              # con id, el server sabe qué pestaña está activa
  theme  = tema_curso,
  header = tags$head(tags$style(HTML(css_propio))),
  fillable = TRUE,

  # ----- Barra lateral compartida por todas las pestañas ----------------------
  sidebar = sidebar(
    title = "Filtros",
    width = 280,
    selectInput("region", "Región:",
                choices = regiones, selected = regiones, multiple = TRUE),

    # conditionalPanel(): la condición se escribe en JavaScript y mira los
    # inputs de la ui. Acá: mostrar este control solo en la pestaña "Gráficos".
    conditionalPanel(
      condition = "input.pestana == 'Gráficos'",
      selectInput("variable", "Variable:", choices = VARIABLES),
      checkboxInput("colorear", "Colorear por región", TRUE)
    ),
    conditionalPanel(
      condition = "input.pestana == 'Tabla'",
      checkboxGroupInput("columnas", "Columnas:",
                         choices = c("Habilitados" = "habilitados",
                                     "Emitidos" = "emitidos",
                                     "Participación" = "participacion_pct",
                                     "Lema ganador" = "lema_ganador",
                                     "Margen" = "margen_pct",
                                     "% SÍ Art. 11" = "pct_si_art11",
                                     "% SÍ Art. 67" = "pct_si_art67"),
                         selected = c("habilitados", "emitidos",
                                      "participacion_pct", "lema_ganador"))
    ),
    hr(),
    input_dark_mode(id = "modo", mode = "light"),   # modo claro / oscuro
    tooltip(
      span("¿Qué es esto?", class = "text-muted small"),
      "El botón de arriba alterna entre modo claro y oscuro. bslib lo resuelve solo."
    )
  ),

  # ----- Pestaña 1: Resumen ----------------------------------------------------
  nav_panel(
    title = "Resumen",
    # layout_columns(): reparte el ancho entre sus hijos (12 columnas).
    layout_columns(
      fill = FALSE,
      value_box("Departamentos", textOutput("vb_deptos"),
                showcase = icon("map"),
                theme = value_box_theme(bg = VIOLETA, fg = "white")),
      value_box("Votos emitidos", textOutput("vb_emitidos"),
                showcase = icon("check-to-slot"),
                theme = value_box_theme(bg = VIOLETA_CLARO, fg = "white")),
      value_box("Participación media", textOutput("vb_participacion"),
                showcase = icon("users"),
                theme = value_box_theme(bg = VIOLETA_PROFUNDO, fg = "white")),
      value_box("Lema con más departamentos", textOutput("vb_lema"),
                showcase = icon("flag"),
                theme = value_box_theme(bg = ACENTO, fg = VIOLETA_PROFUNDO))
    ),
    layout_columns(
      col_widths = c(7, 5),
      card(
        card_header("Ganador por departamento"),
        plotOutput("g_ganador"),
        card_footer(class = "text-muted small",
                    "Porcentaje del lema ganador. Fuente: Corte Electoral.")
      ),
      card(
        card_header("Cómo leer este tablero"),
        # accordion(): secciones plegables.
        accordion(
          open = FALSE,
          accordion_panel("Datos",
                          "Resultados por departamento de la Elección Nacional 2024."),
          accordion_panel("Filtros",
                          "La región filtra todas las pestañas. Los demás controles",
                          " aparecen solo en la pestaña que los usa."),
          accordion_panel("Estética",
                          "Tema de bslib con la paleta violeta del curso.")
        )
      )
    )
  ),

  # ----- Pestaña 2: Gráficos ---------------------------------------------------
  nav_panel(
    title = "Gráficos",
    layout_columns(
      card(card_header("Ranking"),      plotOutput("g_barras")),
      card(card_header("Distribución"), plotOutput("g_caja"))
    )
  ),

  # ----- Pestaña 3: Tabla interactiva (DT) -----------------------------------
  nav_panel(
    title = "Tabla",
    card(
      card_header("Tabla por departamento: ordenar, buscar y exportar"),
      DTOutput("tabla")
    )
  ),

  # ----- Extras de la barra: espacio y un link externo -----------------------
  nav_spacer(),
  nav_item(tags$a("Corte Electoral", href = "https://www.corteelectoral.gub.uy",
                  target = "_blank"))
)

# --- SERVER ------------------------------------------------------------------
server <- function(input, output, session) {

  datos_filtrados <- reactive({
    req(input$region)
    elecciones[elecciones$region %in% input$region, ]
  })

  # ----- Value boxes ---------------------------------------------------------
  output$vb_deptos <- renderText(nrow(datos_filtrados()))
  output$vb_emitidos <- renderText(format(sum(datos_filtrados()$emitidos), big.mark = "."))
  output$vb_participacion <- renderText(
    paste0(round(weighted.mean(datos_filtrados()$participacion_pct,
                               datos_filtrados()$habilitados), 1), "%"))
  output$vb_lema <- renderText(names(which.max(table(datos_filtrados()$lema_ganador))))

  # ----- Gráfico del resumen -------------------------------------------------
  output$g_ganador <- renderPlot({
    d <- datos_filtrados()
    ggplot(d, aes(x = reorder(departamento, pct_ganador), y = pct_ganador,
                  fill = lema_ganador)) +
      geom_col() +
      coord_flip() +
      scale_fill_manual(values = c("Frente Amplio" = "#1f4fa3",
                                   "Partido Nacional" = "#7fb3e8",
                                   "Partido Colorado" = "#d94f3d"), name = NULL) +
      labs(x = NULL, y = "% del lema ganador") +
      tema_ggplot
  }, res = 96)

  # ----- Pestaña Gráficos ----------------------------------------------------
  output$g_barras <- renderPlot({
    d <- datos_filtrados()
    g <- ggplot(d, aes(x = reorder(departamento, .data[[input$variable]]),
                       y = .data[[input$variable]]))
    g <- if (input$colorear) {
      g + geom_col(aes(fill = region)) +
        scale_fill_manual(values = COLORES_REGION, name = NULL)
    } else g + geom_col(fill = VIOLETA)
    g + coord_flip() + labs(x = NULL, y = etiqueta_de(input$variable)) + tema_ggplot
  }, res = 96)

  output$g_caja <- renderPlot({
    d <- datos_filtrados()
    ggplot(d, aes(x = region, y = .data[[input$variable]], fill = region)) +
      geom_boxplot(alpha = .8, show.legend = FALSE) +
      geom_jitter(width = .1, colour = VIOLETA_PROFUNDO) +
      scale_fill_manual(values = COLORES_REGION) +
      labs(x = NULL, y = etiqueta_de(input$variable)) +
      tema_ggplot
  }, res = 96)

  # ----- Tabla DT ------------------------------------------------------------
  output$tabla <- renderDT({
    d <- datos_filtrados()[, c("departamento", "region", input$columnas)]
    datatable(d, rownames = FALSE, filter = "top",
              extensions = "Buttons",
              options = list(pageLength = 10, dom = "Bfrtip",
                             buttons = c("copy", "csv", "excel"),
                             language = DT_ES)) |>
      formatStyle("departamento", fontWeight = "bold")
  })
}

shinyApp(ui = ui, server = server)
