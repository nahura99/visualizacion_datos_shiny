# =============================================================================
# CLASE 6 · El Motor Reactivo
# Curso: Visualización interactiva de datos con R y Shiny (Udelar)
# -----------------------------------------------------------------------------
# Objetivo de la clase
#   - Entender cómo Shiny "escucha" los inputs y recalcula SOLO lo necesario.
#   - Escribir el filtro UNA sola vez con reactive() y reutilizarlo.
#   - Controlar CUÁNDO se recalcula algo: botones, eventReactive(), isolate().
#   - Gestionar errores comunes: req(), validate() + need().
#
# Componentes que se explican en clase
#   reactive()       -> un valor que se recalcula solo cuando cambian sus inputs
#   req()            -> frena el cálculo (sin error) si falta un input
#   validate(need()) -> muestra un mensaje amable en vez de un error rojo
#   eventReactive()  -> recalcula solo cuando pasa un evento (un botón)
#   observeEvent()   -> ejecuta una acción (no devuelve valor) ante un evento
#   isolate()        -> lee un input sin "suscribirse" a sus cambios
#   reactiveVal()    -> una variable reactiva propia del server
#   update*Input()   -> el server cambia un control de la ui
# =============================================================================

library(shiny)
library(bslib)

# --- Estética del curso (se explica en la Clase 8) ---------------------------
VIOLETA_PROFUNDO <- "#2E0A4E"; VIOLETA <- "#5A189A"
VIOLETA_CLARO    <- "#9D4EDD"; ACENTO  <- "#C77DFF"
tema_curso <- bs_theme(
  version = 5, bg = "#FFFFFF", fg = VIOLETA_PROFUNDO,
  primary = VIOLETA, secondary = VIOLETA_CLARO,
  base_font    = font_google("Inter",  local = FALSE),
  heading_font = font_google("Oswald", local = FALSE)
)

# --- Datos (código estático) -------------------------------------------------
ruta <- if (file.exists("datos/elecciones_departamento_2024.csv")) {
  "datos/elecciones_departamento_2024.csv"
} else {
  "../datos/elecciones_departamento_2024.csv"
}
elecciones <- read.csv(ruta, encoding = "UTF-8")
regiones   <- sort(unique(elecciones$region))

# --- UI ----------------------------------------------------------------------
ui <- fluidPage(
  theme = tema_curso,
  titlePanel("Clase 6 · Reactividad: calcular una vez, usar muchas"),

  sidebarLayout(
    sidebarPanel(
      width = 3,
      h4("Filtros inmediatos"),
      selectInput("region", "Región:",
                  choices = regiones, selected = regiones, multiple = TRUE),
      sliderInput("min_part", "Participación mínima (%):",
                  min = 88, max = 92, value = 88, step = 0.1),
      helpText("Si sacás todas las regiones, la app avisa en vez de",
               "romperse (gracias a req() y validate())."),
      actionButton("reiniciar", "Reiniciar filtros", class = "btn-outline-primary"),

      hr(),
      h4("Cálculo bajo demanda"),
      numericInput("umbral", "Margen mínimo del ganador (pp):",
                   value = 10, min = 0, max = 35),
      actionButton("calcular", "Calcular departamentos reñidos",
                   class = "btn-primary"),
      helpText("El umbral NO dispara nada hasta que apretás el botón:",
               "eso es eventReactive().")
    ),

    mainPanel(
      width = 9,
      fluidRow(
        column(4, h5("Departamentos"),  h3(textOutput("n_deptos"))),
        column(4, h5("Votos emitidos"), h3(textOutput("emitidos"))),
        column(4, h5("Veces que se filtró"), h3(textOutput("contador")))
      ),
      hr(),
      tabsetPanel(
        tabPanel("Tabla", br(), tableOutput("tabla")),
        tabPanel("Reñidos (bajo demanda)", br(),
                 p("Departamentos con un margen menor al umbral elegido.",
                   "Se recalcula solo al apretar el botón."),
                 tableOutput("renidos")),
        tabPanel("Bitácora", br(),
                 p("Cada vez que Shiny vuelve a correr el reactive() dejamos",
                   "una línea acá. Mové un control y mirá cuándo aparece."),
                 verbatimTextOutput("bitacora"))
      )
    )
  )
)

# --- SERVER ------------------------------------------------------------------
server <- function(input, output, session) {

  # ----- reactiveVal(): variables propias del server ---------------------------
  # Un contador de cuántas veces se recalculó el filtro y una bitácora.
  veces   <- reactiveVal(0)
  eventos <- reactiveVal(character(0))

  # ----- UN solo reactive con los datos filtrados -----------------------------
  datos_filtrados <- reactive({
    # req(): si no hay ninguna región elegida, frena acá sin error.
    req(input$region)

    d <- elecciones[elecciones$region %in% input$region &
                    elecciones$participacion_pct >= input$min_part, ]

    # validate(need()): si el filtro deja la tabla vacía, mensaje amable.
    validate(need(nrow(d) > 0,
                  "Ningún departamento cumple con estos filtros."))

    # Registramos que el cálculo ocurrió (isolate evita un bucle infinito:
    # leemos veces() sin que este reactive dependa de sí mismo).
    veces(isolate(veces()) + 1)
    eventos(c(isolate(eventos()),
              paste0(format(Sys.time(), "%H:%M:%S"), "  filtro recalculado: ",
                     nrow(d), " departamentos")))
    d
  })

  # ----- Todos los outputs REUTILIZAN datos_filtrados() ----------------------
  output$n_deptos <- renderText(paste0(nrow(datos_filtrados()), " de 19"))
  output$emitidos <- renderText(format(sum(datos_filtrados()$emitidos), big.mark = "."))
  output$contador <- renderText(veces())

  output$tabla <- renderTable({
    d <- datos_filtrados()
    d[order(-d$emitidos),
      c("departamento", "region", "emitidos", "participacion_pct",
        "lema_ganador", "margen_pct")]
  })

  # ----- eventReactive(): recalcular SOLO al apretar el botón -----------------
  # Depende de input$calcular. El umbral y los datos se leen "de paso", sin
  # disparar el cálculo cuando cambian.
  renidos <- eventReactive(input$calcular, {
    d <- datos_filtrados()
    d <- d[d$margen_pct < input$umbral, ]
    validate(need(nrow(d) > 0, "Ningún departamento por debajo de ese margen."))
    d[order(d$margen_pct), c("departamento", "lema_ganador", "pct_ganador", "margen_pct")]
  })
  output$renidos <- renderTable(renidos())

  # ----- observeEvent(): una ACCIÓN ante un evento ---------------------------
  # No devuelve un valor: modifica controles de la ui con update*Input().
  observeEvent(input$reiniciar, {
    updateSelectInput(session, "region", selected = regiones)
    updateSliderInput(session, "min_part", value = 88)
    eventos(c(eventos(), paste0(format(Sys.time(), "%H:%M:%S"),
                                "  botón 'Reiniciar' apretado")))
  })

  output$bitacora <- renderPrint({
    cat(rev(eventos()), sep = "\n")
  })
}

shinyApp(ui = ui, server = server)
