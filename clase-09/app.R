# =============================================================================
# CLASE 9 · Puesta en Producción: la app final
# Curso: Visualización interactiva de datos con R y Shiny (Udelar)
# -----------------------------------------------------------------------------
# Objetivo de la clase
#   - Integrar TODO lo aprendido en una app compleja con TRES paneles:
#       * Gráficos  (4 visualizaciones con ggplot2 y plotly)
#       * Tablas    (4 tablas interactivas con DT)
#       * Mapas     (4 mapas georreferenciados con leaflet)
#   - Depurar errores comunes: rutas, paquetes, filtros vacíos, datos NA.
#   - Publicar la app en shinyapps.io (ver deploy.R y ../GUIA-DEPLOY.md).
#
# Componentes nuevos que se explican en clase
#   leaflet(), addProviderTiles(), addCircleMarkers(), addLegend()
#   leafletProxy()   -> actualizar un mapa sin redibujarlo entero
#   colorNumeric()   -> escala de color continua
#   validate(need()) en todos los cálculos; tryCatch() al leer datos
#   options(shiny.sanitize.errors) y rsconnect::deployApp()
#
# Organización del archivo (en una app grande esto se separa en global.R,
# ui.R y server.R; acá va todo junto para leerlo de punta a punta):
#   1. Paquetes y estética     2. Datos y constantes     3. Funciones auxiliares
#   4. UI                      5. Server
# =============================================================================

# ---- 1. Paquetes y estética -------------------------------------------------
library(shiny)
library(bslib)
library(ggplot2)
library(plotly)
library(DT)
library(leaflet)
library(scales)

VIOLETA_PROFUNDO <- "#2E0A4E"; VIOLETA <- "#5A189A"
VIOLETA_CLARO    <- "#9D4EDD"; ACENTO  <- "#C77DFF"

tema_curso <- bs_theme(
  version = 5, bg = "#FFFFFF", fg = VIOLETA_PROFUNDO,
  primary = VIOLETA, secondary = VIOLETA_CLARO,
  base_font    = font_google("Inter",  local = FALSE),
  heading_font = font_google("Oswald", local = FALSE),
  "navbar-bg"  = VIOLETA_PROFUNDO, "navbar-fg" = "#FFFFFF"
)
css_propio <- "
  .navbar-brand { font-family: 'Oswald', sans-serif; letter-spacing: .5px; }
  .card-header  { font-family: 'Oswald', sans-serif; font-size: 1.05rem; }
  .leaflet-container { border-radius: 8px; }
"
COLORES_REGION <- c(Metropolitana = "#2E0A4E", Litoral = "#5A189A",
                    Norte = "#7B2CBF", Centro = "#9D4EDD", Este = "#C77DFF")
# Colores partidarios: se usan SOLO cuando el dato es un partido. El resto de
# la interfaz mantiene la paleta violeta del curso.
COLORES_LEMA <- c(
  "Frente Amplio"         = "#1f4fa3", "Partido Nacional"      = "#7fb3e8",
  "Partido Colorado"      = "#d94f3d", "Cabildo Abierto"       = "#f2b134",
  "Identidad Soberana"    = "#5bb98c", "Partido Independiente" = "#8e6bbf",
  "Const Ambientalista"   = "#2f9e8f", "Asamblea Popular"      = "#b03a5b",
  "Ecologista Radical"    = "#6b8f3a", "Cambios Necesarios"    = "#9b7653",
  "Avanzar Republicano"   = "#7a7a7a"
)
color_lema <- function(x) unname(ifelse(is.na(x) | !(x %in% names(COLORES_LEMA)),
                                        "#9e9e9e", COLORES_LEMA[x]))
tema_ggplot <- theme_minimal(base_size = 13) + theme(legend.position = "bottom")

# En producción, los errores de R no se muestran al usuario con detalle.
options(shiny.sanitize.errors = FALSE)   # poné TRUE al publicar

# ---- 2. Datos y constantes --------------------------------------------------
# Los datos viajan con la app: al publicar, rsconnect sube la carpeta datos/.
buscar <- function(archivo) {
  candidatos <- c(file.path("datos", archivo), file.path("..", "datos", archivo))
  existe <- candidatos[file.exists(candidatos)]
  if (!length(existe)) stop("No encuentro el archivo de datos: ", archivo)
  existe[1]
}
leer <- function(archivo) {
  tryCatch(read.csv(buscar(archivo), encoding = "UTF-8", check.names = FALSE),
           error = function(e) { message("Error leyendo ", archivo, ": ", e$message); NULL })
}
elecciones <- leer("elecciones_departamento_2024.csv")
locales    <- leer("elecciones_locales_2024.csv")
circuitos  <- leer("elecciones_circuitos_2024.csv")
stopifnot(!is.null(elecciones), !is.null(locales), !is.null(circuitos))

DEPARTAMENTOS <- sort(unique(elecciones$departamento))
REGIONES      <- sort(unique(elecciones$region))

VARIABLES_DEPTO <- c("Participación (%)"       = "participacion_pct",
                     "Margen del ganador (pp)" = "margen_pct",
                     "Personas habilitadas"    = "habilitados",
                     "Votos emitidos"          = "emitidos",
                     "% Frente Amplio"         = "pct_frente_amplio",
                     "% Partido Nacional"      = "pct_partido_nacional",
                     "% Partido Colorado"      = "pct_partido_colorado",
                     "% Cabildo Abierto"       = "pct_cabildo_abierto",
                     "% SÍ Art. 11"            = "pct_si_art11",
                     "% SÍ Art. 67"            = "pct_si_art67")
etiqueta_de <- function(v, lista = VARIABLES_DEPTO) names(lista)[lista == v]

# Lemas: se derivan de las columnas Votos_* para no escribir la lista a mano.
vote_cols   <- grep("^Votos_", names(circuitos), value = TRUE)
orden_lemas <- names(sort(colSums(circuitos[vote_cols], na.rm = TRUE), decreasing = TRUE))
lema_label  <- gsub("_", " ", sub("^Votos_", "", orden_lemas))
LEMAS       <- setNames(orden_lemas, lema_label)

INDICADORES <- c("Participación (votos propios / habilitados)" = "PctParticipacionPropios",
                 "Participación (emitidos / habilitados)"      = "PctParticipacion",
                 "Voto en blanco (%)"                          = "PctEnBlanco",
                 "Voto anulado (%)"                            = "PctAnulados",
                 "Voto observado (%)"                          = "PctObservados",
                 "Margen del ganador (puntos)"                 = "MargenGanadorPct")
PLEBISCITOS <- c("SÍ al Art. 11 (allanamientos nocturnos)" = "PctSiArt11",
                 "SÍ al Art. 67 (seguridad social)"        = "PctSiArt67")
VARIABLES_LOCAL <- c(INDICADORES, PLEBISCITOS,
                     setNames(paste0("Pct_", sub("^Votos_", "", orden_lemas)),
                              paste0("% ", lema_label)))

# Valor nacional de cada variable, para la escala "relativa al país".
promedio_nacional <- local({
  n <- list()
  tot_val <- sum(circuitos$TotalVotosLemas, na.rm = TRUE)
  tot_emi <- sum(circuitos$TotalVotosEmitidos, na.rm = TRUE)
  tot_hab <- sum(circuitos$TotalHabilitados, na.rm = TRUE)
  tot_nob <- sum(circuitos$TotalVotosNoObservados, na.rm = TRUE)
  for (vc in vote_cols)
    n[[paste0("Pct_", sub("^Votos_", "", vc))]] <- 100 * sum(circuitos[[vc]], na.rm = TRUE) / tot_val
  n$PctSiArt11 <- 100 * sum(circuitos$SiArt11, na.rm = TRUE) / tot_nob
  n$PctSiArt67 <- 100 * sum(circuitos$SiArt67, na.rm = TRUE) / tot_nob
  n$PctParticipacion        <- 100 * tot_emi / tot_hab
  n$PctParticipacionPropios <- 100 * tot_nob / tot_hab
  n$PctEnBlanco   <- 100 * sum(circuitos$TotalEnBlanco, na.rm = TRUE) / tot_emi
  n$PctAnulados   <- 100 * sum(circuitos$TotalAnulados, na.rm = TRUE) / tot_emi
  n$PctObservados <- 100 * sum(circuitos$TotalVotosObservados, na.rm = TRUE) / tot_emi
  n$MargenGanadorPct <- stats::median(circuitos$MargenGanadorPct, na.rm = TRUE)
  lapply(n, round, 1)
})

DT_ES <- list(
  lengthMenu = "Mostrar _MENU_ filas", search = "Buscar:",
  info = "Mostrando _START_ a _END_ de _TOTAL_ filas", infoEmpty = "Sin filas",
  infoFiltered = "(filtrado de _MAX_ filas)", zeroRecords = "No se encontraron resultados",
  paginate = list(first = "Primero", last = "Último", `next` = "Siguiente", previous = "Anterior")
)

# ---- 3. Funciones auxiliares ------------------------------------------------
fmt_n   <- function(x) ifelse(is.na(x), "s/d", format(round(as.numeric(x)), big.mark = ".",
                                                      decimal.mark = ",", trim = TRUE))
fmt_pct <- function(x) ifelse(is.na(x), "s/d", paste0(format(round(as.numeric(x), 1), nsmall = 1,
                                                              decimal.mark = ",", trim = TRUE), "%"))

# Radio del círculo según votos emitidos: legible en Montevideo y en el campo.
radio_por_votos <- function(v) {
  v  <- ifelse(is.na(v) | v < 0, 0, v)
  mx <- suppressWarnings(max(v, na.rm = TRUE))
  if (!is.finite(mx) || mx <= 0) return(rep(5, length(v)))
  rescale(sqrt(v), to = c(3, 13), from = c(0, sqrt(mx)))
}
# Límites robustos (percentiles 2 y 98) para que un circuito de 12 votos con
# 100% para un partido no aplaste el gradiente.
limites_robustos <- function(v, p = 0.02) {
  v <- v[is.finite(v)]
  if (!length(v)) return(NULL)
  lim <- unname(stats::quantile(v, c(p, 1 - p)))
  if (diff(lim) <= 0) lim <- range(v)
  if (diff(lim) <= 0) lim <- lim + c(-1, 1)
  round(lim, 1)
}
limites_simetricos <- function(v, centro, p = 0.02) {
  lim <- limites_robustos(v, p)
  if (is.null(lim)) return(NULL)
  d <- max(abs(lim - centro))
  round(c(centro - d, centro + d), 1)
}
RAMPA_DIVERGENTE <- c("#b35806", "#e08214", "#fdb863", "#f7f7f7", "#80cdc1", "#35978f", "#01665e")

popup_html <- function(d) {
  encabezado <- if ("CantidadCircuitos" %in% names(d)) {
    paste0("<b>", d$NombreLocal, "</b><br/><span style='color:#666'>", d$Localidad, ", ",
           d$DepartamentoNombre, " · circuitos: ", d$Circuitos, "</span>")
  } else {
    paste0("<b>Circuito ", d$CRV, "</b> · ", d$DepartamentoNombre,
           "<br/><span style='color:#666'>", d$NombreLocal, ", ", d$Localidad, "</span>")
  }
  filas <- vapply(seq_len(nrow(d)), function(i) {
    v <- unlist(d[i, orden_lemas]); p <- unlist(d[i, paste0("Pct_", sub("^Votos_", "", orden_lemas))])
    k <- which(v > 0)
    if (!length(k)) return("<i>sin votos registrados</i>")
    paste0("<table style='font-size:11px;margin-top:4px'>",
           paste0("<tr><td><span style='display:inline-block;width:9px;height:9px;background:",
                  color_lema(lema_label[k]), ";border-radius:2px'></span></td><td style='padding:0 8px'>",
                  lema_label[k], "</td><td style='text-align:right'>", fmt_n(v[k]),
                  "</td><td style='text-align:right;color:#666;padding-left:8px'>", fmt_pct(p[k]),
                  "</td></tr>", collapse = ""),
           "</table>")
  }, character(1))
  paste0("<div style='font-family:system-ui,sans-serif;font-size:12px;min-width:240px'>", encabezado,
         "<hr style='margin:6px 0'/>Habilitados: <b>", fmt_n(d$TotalHabilitados),
         "</b> · Emitidos: <b>", fmt_n(d$TotalVotosEmitidos), "</b><br/>Participación: <b>",
         fmt_pct(d$PctParticipacionPropios), "</b>", filas,
         "<hr style='margin:6px 0'/><span style='font-size:11px'>SÍ Art. 11: <b>", fmt_pct(d$PctSiArt11),
         "</b> · SÍ Art. 67: <b>", fmt_pct(d$PctSiArt67), "</b></span><br/>",
         "<span style='font-size:10px;color:#888'>Precisión: ", d$Precision, "</span></div>")
}

# Un mapa base vacío. Los cuatro mapas parten de acá.
mapa_base <- function() {
  leaflet(options = leafletOptions(preferCanvas = TRUE)) |>
    addProviderTiles("CartoDB.Positron", group = "Claro") |>
    addProviderTiles("Esri.WorldImagery", group = "Satelital") |>
    addLayersControl(baseGroups = c("Claro", "Satelital"),
                     options = layersControlOptions(collapsed = TRUE)) |>
    setView(lng = -56.0, lat = -32.8, zoom = 6)
}

# Pinta los puntos de un mapa. `modo` decide el color:
#   "ganador"  -> color partidario del lema ganador
#   cualquier otra cosa -> escala continua sobre la columna `var`
pintar_mapa <- function(id, d, modo, var = NULL, titulo = "", relativo = FALSE,
                        rampa = c("#f7f7f7", VIOLETA), nivel = "local") {
  proxy <- leafletProxy(id) |> clearMarkers() |> clearControls()
  if (!nrow(d)) return(invisible(proxy))
  radios <- radio_por_votos(d$TotalVotosEmitidos)

  if (modo == "ganador") {
    cols <- color_lema(d$LemaGanador)
    presentes <- intersect(lema_label, unique(d$LemaGanador))
    proxy <- proxy |> addLegend("bottomright", colors = color_lema(presentes),
                                labels = presentes, title = "Lema ganador", opacity = .9)
    texto <- ifelse(is.na(d$LemaGanador), "s/d", d$LemaGanador)
  } else {
    v <- d[[var]]
    if (all(is.na(v))) {
      cols <- rep("#9e9e9e", nrow(d))
    } else if (relativo && !is.null(promedio_nacional[[var]])) {
      centro <- promedio_nacional[[var]]
      lim <- limites_simetricos(v, centro)
      pal <- colorNumeric(RAMPA_DIVERGENTE, domain = lim, na.color = "#cccccc")
      cols <- pal(pmin(pmax(v, lim[1]), lim[2]))
      proxy <- proxy |> addLegend("bottomright", pal = pal, values = lim, opacity = .9,
                                  title = htmltools::HTML(paste0(titulo, "<br/><small>país = ",
                                                                 fmt_pct(centro), "</small>")),
                                  labFormat = labelFormat(suffix = "%"))
    } else {
      lim <- limites_robustos(v)
      pal <- colorNumeric(rampa, domain = lim, na.color = "#cccccc")
      cols <- pal(pmin(pmax(v, lim[1]), lim[2]))
      proxy <- proxy |> addLegend("bottomright", pal = pal, values = lim, title = titulo,
                                  labFormat = labelFormat(suffix = "%"), opacity = .9)
    }
    texto <- fmt_pct(v)
  }
  etiquetas <- paste0(if (nivel == "local") d$NombreLocal else paste0("Circuito ", d$CRV), " · ", texto)
  proxy |> addCircleMarkers(lng = d$Longitud, lat = d$Latitud, radius = radios,
                            color = "#333333", weight = .5, opacity = .6,
                            fillColor = cols, fillOpacity = .85, label = etiquetas,
                            popup = popup_html(d), popupOptions = popupOptions(maxWidth = 340))
}

tabla_dt <- function(d, ...) {
  datatable(d, rownames = FALSE, extensions = "Buttons",
            options = list(pageLength = 10, scrollX = TRUE, dom = "Bfrtip",
                           buttons = c("copy", "csv", "excel"), language = DT_ES), ...)
}

# ---- 4. UI ------------------------------------------------------------------
ui <- page_navbar(
  title = "Elecciones Nacionales 2024 · Uruguay",
  id = "pestana", theme = tema_curso, fillable = FALSE,
  header = tags$head(tags$style(HTML(css_propio))),

  sidebar = sidebar(
    title = "Filtros", width = 300,
    selectizeInput("depto", "Departamento:", choices = c("Todos", DEPARTAMENTOS),
                   selected = "Todos", multiple = TRUE,
                   options = list(plugins = list("remove_button"))),
    hr(),

    # ----- Controles de Gráficos ---------------------------------------------
    conditionalPanel(
      "input.pestana == 'Gráficos'",
      selectInput("var_y", "Variable (ranking y eje Y):", choices = VARIABLES_DEPTO),
      selectInput("var_x", "Variable del eje X (dispersión):", choices = VARIABLES_DEPTO,
                  selected = "margen_pct"),
      checkboxInput("colorear", "Colorear por región", TRUE)
    ),

    # ----- Controles de Tablas -----------------------------------------------
    conditionalPanel(
      "input.pestana == 'Tablas'",
      selectInput("var_rank", "Variable del ranking de locales:", choices = VARIABLES_LOCAL,
                  selected = "PctParticipacionPropios"),
      sliderInput("n_rank", "Cantidad en el ranking:", min = 5, max = 30, value = 10),
      sliderInput("min_hab_tabla", "Mínimo de habilitados por local:",
                  min = 0, max = 1000, value = 100, step = 50),
      downloadButton("descargar_locales", "Descargar locales (.csv)", class = "btn-primary btn-sm")
    ),

    # ----- Controles de Mapas ------------------------------------------------
    conditionalPanel(
      "input.pestana == 'Mapas'",
      radioButtons("nivel", "Unidad:", inline = TRUE,
                   choices = c("Local de votación" = "local", "Circuito" = "circuito")),
      selectInput("lema", "Lema (mapa 2):", choices = LEMAS),
      selectInput("pleb", "Plebiscito (mapa 3):", choices = PLEBISCITOS),
      selectInput("indicador", "Indicador (mapa 4):", choices = INDICADORES),
      checkboxInput("relativo", "Escala relativa al promedio nacional", FALSE),
      helpText(style = "font-size:11px", "Activada, los mapas 2 a 4 pintan la desviación",
               "respecto del país: verde por encima, naranja por debajo."),
      sliderInput("min_hab_mapa", "Mínimo de habilitados:", min = 0, max = 1000, value = 0, step = 50),
      checkboxInput("solo_precisos", "Solo coordenadas de precisión alta o media", FALSE),
      downloadButton("descargar_mapa", "Descargar selección (.csv)", class = "btn-primary btn-sm")
    )
  ),

  # =========================== PANEL 1: GRÁFICOS ==============================
  nav_panel(
    title = "Gráficos",
    layout_columns(
      fill = FALSE,
      value_box("Departamentos", textOutput("vb_deptos"), showcase = icon("map"),
                theme = value_box_theme(bg = VIOLETA, fg = "white")),
      value_box("Votos emitidos", textOutput("vb_emitidos"), showcase = icon("check-to-slot"),
                theme = value_box_theme(bg = VIOLETA_CLARO, fg = "white")),
      value_box("Participación", textOutput("vb_participacion"), showcase = icon("users"),
                theme = value_box_theme(bg = VIOLETA_PROFUNDO, fg = "white")),
      value_box("Lema más votado", textOutput("vb_lema"), showcase = icon("flag"),
                theme = value_box_theme(bg = ACENTO, fg = VIOLETA_PROFUNDO))
    ),
    layout_columns(
      card(card_header("1 · Ranking por departamento"), plotOutput("g_ranking", height = 420)),
      card(card_header("2 · Dispersión (interactiva)"), plotlyOutput("g_dispersion", height = 420))
    ),
    layout_columns(
      card(card_header("3 · Composición del voto por lema"), plotOutput("g_composicion", height = 420)),
      card(card_header("4 · Plebiscitos: SÍ Art. 11 vs. SÍ Art. 67"), plotOutput("g_plebiscitos", height = 420))
    )
  ),

  # =========================== PANEL 2: TABLAS ================================
  nav_panel(
    title = "Tablas",
    layout_columns(
      col_widths = c(8, 4),
      card(card_header("1 · Resultados por departamento"), DTOutput("t_deptos")),
      card(card_header("2 · Resumen por región"), DTOutput("t_regiones"))
    ),
    card(
      card_header(textOutput("titulo_ranking")),
      layout_columns(
        div(h6("Mayor valor"), DTOutput("t_top")),
        div(h6("Menor valor"), DTOutput("t_bottom"))
      ),
      card_footer(class = "text-muted small",
                  "3 · Se excluyen los locales con menos habilitados que el mínimo elegido.")
    ),
    card(card_header("4 · Todos los locales de votación (filtros por columna)"), DTOutput("t_locales"))
  ),

  # =========================== PANEL 3: MAPAS =================================
  nav_panel(
    title = "Mapas",
    layout_columns(
      fill = FALSE,
      value_box(textOutput("vb_unidades_titulo"), textOutput("vb_unidades"),
                theme = value_box_theme(bg = VIOLETA, fg = "white")),
      value_box("Habilitados", textOutput("vb_hab_mapa"),
                theme = value_box_theme(bg = VIOLETA_CLARO, fg = "white")),
      value_box("Participación", textOutput("vb_part_mapa"),
                theme = value_box_theme(bg = VIOLETA_PROFUNDO, fg = "white")),
      uiOutput("vb_ganador_mapa")
    ),
    layout_columns(
      card(card_header("1 · Lema ganador"),           leafletOutput("m_ganador", height = 440)),
      card(card_header(textOutput("h_lema")),         leafletOutput("m_lema", height = 440))
    ),
    layout_columns(
      card(card_header(textOutput("h_pleb")),         leafletOutput("m_pleb", height = 440)),
      card(card_header(textOutput("h_indicador")),    leafletOutput("m_indicador", height = 440))
    ),
    p(class = "text-muted small",
      "Los circuitos fictos (numeración 9000+) escrutan votos observados: no tienen local",
      " físico, por eso no aparecen en los mapas pero sí en los totales.")
  ),

  nav_spacer(),
  nav_panel(
    title = "Acerca de",
    card(
      card_header("Sobre esta app"),
      p("App final del curso ", em("Visualización interactiva de datos con R y Shiny"),
        " (Udelar). Integra gráficos, tablas y mapas sobre la Elección Nacional 2024."),
      p(strong("Fuentes: "), "Corte Electoral (plan circuital, totales por CRV, plebiscitos) ",
        "e IDE Uruguay (geocodificación de locales)."),
      p(strong("Publicación: "), "ver ", code("deploy.R"), " en esta carpeta y ",
        code("GUIA-DEPLOY.md"), " en la raíz del repositorio."),
      verbatimTextOutput("info_sesion")
    )
  )
)

# ---- 5. SERVER --------------------------------------------------------------
server <- function(input, output, session) {

  # ======================= DATOS FILTRADOS (compartidos) =====================
  deptos_elegidos <- reactive({
    req(input$depto)
    if ("Todos" %in% input$depto) DEPARTAMENTOS else input$depto
  })

  datos_depto <- reactive({
    d <- elecciones[elecciones$departamento %in% deptos_elegidos(), ]
    validate(need(nrow(d) > 0, "No hay departamentos con estos filtros."))
    d
  })

  # Locales para las tablas (nivel local, mínimo de habilitados propio).
  locales_tabla <- reactive({
    l <- locales[locales$DepartamentoNombre %in% deptos_elegidos() &
                 !is.na(locales$TotalHabilitados) &
                 locales$TotalHabilitados >= input$min_hab_tabla, ]
    validate(need(nrow(l) > 0, "No hay locales con estos filtros."))
    l
  })

  # Unidades para los mapas (local o circuito, con sus propios filtros).
  datos_mapa <- reactive({
    d <- if (input$nivel == "local") locales else circuitos
    d <- d[d$DepartamentoNombre %in% deptos_elegidos(), ]
    if (input$min_hab_mapa > 0)
      d <- d[!is.na(d$TotalHabilitados) & d$TotalHabilitados >= input$min_hab_mapa, ]
    if (isTRUE(input$solo_precisos)) d <- d[grepl("^ALTA|^MEDIA", d$Precision), ]
    d
  })
  datos_mapa_geo <- reactive({
    d <- datos_mapa()
    d[!is.na(d$Latitud) & !is.na(d$Longitud), ]
  })

  # ============================ PANEL 1: GRÁFICOS ============================
  output$vb_deptos <- renderText(nrow(datos_depto()))
  output$vb_emitidos <- renderText(format(sum(datos_depto()$emitidos), big.mark = "."))
  output$vb_participacion <- renderText(
    paste0(round(100 * sum(datos_depto()$emitidos) / sum(datos_depto()$habilitados), 1), "%"))
  output$vb_lema <- renderText({
    d <- datos_depto()
    tot <- c("Frente Amplio" = sum(d$votos_frente_amplio), "Partido Nacional" = sum(d$votos_partido_nacional),
             "Partido Colorado" = sum(d$votos_partido_colorado), "Cabildo Abierto" = sum(d$votos_cabildo_abierto))
    names(tot)[which.max(tot)]
  })

  # 1) Ranking
  output$g_ranking <- renderPlot({
    d <- datos_depto()
    g <- ggplot(d, aes(x = reorder(departamento, .data[[input$var_y]]), y = .data[[input$var_y]]))
    g <- if (input$colorear) g + geom_col(aes(fill = region)) +
      scale_fill_manual(values = COLORES_REGION, name = NULL) else g + geom_col(fill = VIOLETA)
    g + coord_flip() + labs(x = NULL, y = etiqueta_de(input$var_y)) + tema_ggplot
  }, res = 96)

  # 2) Dispersión interactiva (plotly)
  output$g_dispersion <- renderPlotly({
    d <- datos_depto()
    g <- ggplot(d, aes(x = .data[[input$var_x]], y = .data[[input$var_y]],
                       colour = region, text = departamento)) +
      geom_point(size = 4, alpha = .9) +
      scale_colour_manual(values = COLORES_REGION, name = NULL) +
      scale_x_continuous(labels = comma) + scale_y_continuous(labels = comma) +
      labs(x = etiqueta_de(input$var_x), y = etiqueta_de(input$var_y)) + tema_ggplot
    ggplotly(g, tooltip = c("text", "x", "y")) |> layout(legend = list(orientation = "h", y = -0.2))
  })

  # 3) Composición del voto por lema (barras apiladas al 100%)
  output$g_composicion <- renderPlot({
    d <- datos_depto()
    largo <- rbind(
      data.frame(departamento = d$departamento, lema = "Frente Amplio",    pct = d$pct_frente_amplio),
      data.frame(departamento = d$departamento, lema = "Partido Nacional", pct = d$pct_partido_nacional),
      data.frame(departamento = d$departamento, lema = "Partido Colorado", pct = d$pct_partido_colorado),
      data.frame(departamento = d$departamento, lema = "Cabildo Abierto",  pct = d$pct_cabildo_abierto))
    largo$lema <- factor(largo$lema, levels = c("Frente Amplio", "Partido Nacional",
                                                "Partido Colorado", "Cabildo Abierto"))
    ggplot(largo, aes(x = reorder(departamento, pct * (lema == "Frente Amplio")), y = pct, fill = lema)) +
      geom_col(position = "stack") +
      coord_flip() +
      scale_fill_manual(values = COLORES_LEMA, name = NULL) +
      labs(x = NULL, y = "% de los votos válidos (cuatro lemas principales)") + tema_ggplot
  }, res = 96)

  # 4) Plebiscitos (gráfico de "pesas")
  output$g_plebiscitos <- renderPlot({
    d <- datos_depto()
    d$departamento <- reorder(d$departamento, d$pct_si_art11)
    ggplot(d) +
      geom_segment(aes(x = pct_si_art67, xend = pct_si_art11, y = departamento, yend = departamento),
                   colour = "grey70", linewidth = 1.2) +
      geom_point(aes(x = pct_si_art67, y = departamento, colour = "SÍ Art. 67 (seguridad social)"), size = 3.5) +
      geom_point(aes(x = pct_si_art11, y = departamento, colour = "SÍ Art. 11 (allanamientos)"), size = 3.5) +
      geom_vline(xintercept = 50, linetype = "dashed", colour = VIOLETA_PROFUNDO) +
      scale_colour_manual(values = c("SÍ Art. 11 (allanamientos)" = VIOLETA,
                                     "SÍ Art. 67 (seguridad social)" = ACENTO), name = NULL) +
      labs(x = "% de SÍ (la línea marca el 50%)", y = NULL) + tema_ggplot
  }, res = 96)

  # ============================ PANEL 2: TABLAS ==============================
  # 1) Departamentos
  output$t_deptos <- renderDT({
    d <- datos_depto()[, c("departamento", "region", "habilitados", "emitidos", "participacion_pct",
                           "lema_ganador", "pct_ganador", "margen_pct", "pct_si_art11", "pct_si_art67")]
    names(d) <- c("Departamento", "Región", "Habilitados", "Emitidos", "Particip. %", "Ganador",
                  "% ganador", "Margen", "SÍ Art.11", "SÍ Art.67")
    tabla_dt(d, filter = "top") |>
      formatCurrency(c("Habilitados", "Emitidos"), currency = "", mark = ".", digits = 0) |>
      formatStyle("Ganador", color = styleEqual(names(COLORES_LEMA), unname(COLORES_LEMA)), fontWeight = "bold")
  })

  # 2) Regiones (agregación con aggregate(), sin paquetes extra)
  output$t_regiones <- renderDT({
    d <- datos_depto()
    r <- aggregate(cbind(habilitados, emitidos, votos_frente_amplio, votos_partido_nacional,
                         votos_partido_colorado) ~ region, data = d, FUN = sum)
    r$Departamentos <- as.vector(table(d$region)[r$region])
    r$`Particip. %` <- round(100 * r$emitidos / r$habilitados, 1)
    r$`% FA` <- round(100 * r$votos_frente_amplio / r$emitidos, 1)
    r$`% PN` <- round(100 * r$votos_partido_nacional / r$emitidos, 1)
    r$`% PC` <- round(100 * r$votos_partido_colorado / r$emitidos, 1)
    r <- r[order(-r$emitidos), c("region", "Departamentos", "emitidos", "Particip. %", "% FA", "% PN", "% PC")]
    names(r)[c(1, 3)] <- c("Región", "Emitidos")
    datatable(r, rownames = FALSE, options = list(dom = "t", language = DT_ES)) |>
      formatCurrency("Emitidos", currency = "", mark = ".", digits = 0)
  })

  # 3) Ranking de locales (mayor y menor)
  output$titulo_ranking <- renderText(paste0("3 · Ranking de locales: ",
                                             etiqueta_de(input$var_rank, VARIABLES_LOCAL)))
  ranking <- function(desc) {
    l <- locales_tabla()
    l <- l[!is.na(l[[input$var_rank]]), ]
    l <- head(l[order(l[[input$var_rank]], decreasing = desc), ], input$n_rank)
    out <- data.frame(Local = l$NombreLocal, Localidad = l$Localidad, Depto = l$DepartamentoNombre,
                      Habilitados = l$TotalHabilitados, Valor = round(l[[input$var_rank]], 1),
                      check.names = FALSE)
    datatable(out, rownames = FALSE,
              options = list(dom = "t", pageLength = 30, ordering = FALSE, language = DT_ES)) |>
      formatStyle("Valor", fontWeight = "bold", color = VIOLETA)
  }
  output$t_top    <- renderDT(ranking(TRUE))
  output$t_bottom <- renderDT(ranking(FALSE))

  # 4) Todos los locales, con filtros por columna
  output$t_locales <- renderDT({
    l <- locales_tabla()
    cols <- c("DepartamentoNombre", "Localidad", "NombreLocal", "CantidadCircuitos", "TotalHabilitados",
              "TotalVotosEmitidos", "PctParticipacionPropios", "LemaGanador", "MargenGanadorPct",
              "Pct_Frente_Amplio", "Pct_Partido_Nacional", "Pct_Partido_Colorado", "PctSiArt11", "PctSiArt67")
    tabla_dt(l[, cols], filter = "top") |>
      formatRound(grep("^Pct|Margen", cols, value = TRUE), 1)
  })

  output$descargar_locales <- downloadHandler(
    filename = function() paste0("locales_2024_", Sys.Date(), ".csv"),
    content  = function(f) write.csv(locales_tabla(), f, row.names = FALSE, fileEncoding = "UTF-8"))

  # ============================ PANEL 3: MAPAS ===============================
  output$vb_unidades_titulo <- renderText(if (input$nivel == "local") "Locales" else "Circuitos")
  output$vb_unidades <- renderText(fmt_n(nrow(datos_mapa())))
  output$vb_hab_mapa <- renderText(fmt_n(sum(datos_mapa()$TotalHabilitados, na.rm = TRUE)))
  output$vb_part_mapa <- renderText({
    d <- datos_mapa()
    hab <- sum(d$TotalHabilitados, na.rm = TRUE)
    fmt_pct(if (hab > 0) 100 * sum(d$TotalVotosEmitidos, na.rm = TRUE) / hab else NA)
  })
  output$vb_ganador_mapa <- renderUI({
    d <- datos_mapa()
    tot <- colSums(d[orden_lemas], na.rm = TRUE)
    gan <- if (sum(tot) > 0) lema_label[which.max(tot)] else "s/d"
    value_box("Más votado", gan, theme = value_box_theme(bg = color_lema(gan), fg = "white"))
  })

  # Títulos dinámicos de las cards
  output$h_lema      <- renderText(paste0("2 · % ", names(LEMAS)[LEMAS == input$lema]))
  output$h_pleb      <- renderText(paste0("3 · ", names(PLEBISCITOS)[PLEBISCITOS == input$pleb]))
  output$h_indicador <- renderText(paste0("4 · ", names(INDICADORES)[INDICADORES == input$indicador]))

  # Los cuatro mapas se crean vacíos una sola vez...
  output$m_ganador   <- renderLeaflet(mapa_base())
  output$m_lema      <- renderLeaflet(mapa_base())
  output$m_pleb      <- renderLeaflet(mapa_base())
  output$m_indicador <- renderLeaflet(mapa_base())

  # ...y se repintan con leafletProxy() cada vez que cambian los filtros.
  observe({
    d <- datos_mapa_geo()
    pintar_mapa("m_ganador", d, "ganador", nivel = input$nivel)
  })
  observe({
    d <- datos_mapa_geo()
    var <- paste0("Pct_", sub("^Votos_", "", input$lema))
    nombre <- names(LEMAS)[LEMAS == input$lema]
    pintar_mapa("m_lema", d, "continuo", var, paste0("% ", nombre), input$relativo,
                rampa = c("#f7f7f7", color_lema(nombre)), nivel = input$nivel)
  })
  observe({
    d <- datos_mapa_geo()
    pintar_mapa("m_pleb", d, "continuo", input$pleb, names(PLEBISCITOS)[PLEBISCITOS == input$pleb],
                input$relativo, rampa = c("#f7f7f7", VIOLETA_PROFUNDO), nivel = input$nivel)
  })
  observe({
    d <- datos_mapa_geo()
    pintar_mapa("m_indicador", d, "continuo", input$indicador,
                names(INDICADORES)[INDICADORES == input$indicador], input$relativo,
                rampa = c("#f7f7f7", VIOLETA), nivel = input$nivel)
  })

  output$descargar_mapa <- downloadHandler(
    filename = function() paste0("elecciones2024_", input$nivel, "_", Sys.Date(), ".csv"),
    content  = function(f) write.csv(datos_mapa(), f, row.names = FALSE, fileEncoding = "UTF-8"))

  # ============================ ACERCA DE ====================================
  output$info_sesion <- renderPrint({
    cat("R", R.version$major, ".", R.version$minor, " · shiny ", as.character(packageVersion("shiny")),
        " · bslib ", as.character(packageVersion("bslib")), " · leaflet ",
        as.character(packageVersion("leaflet")), "\n", sep = "")
  })
}

shinyApp(ui = ui, server = server)
