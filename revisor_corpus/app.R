# =============================================================================
# CLASE 9 · Tus datos, lo que faltaba y los límites de Shiny
#
# Una app para revisar tu propio corpus antes de construir tu Shiny.
# Subís un CSV, la app lo lee, lo muestra y te dice si tiene problemas.
# =============================================================================

library(shiny)
library(bslib)
library(DT)        # tablas interactivas

################################################################################

## ZONA DE PRUEBAS
TITULO <- "Revisor de corpus"

# COLORES
COLOR_PRINCIPAL  <- "#5A189A"   # cajas de números, botones, barras
COLOR_SECUNDARIO <- "#9D4EDD"
COLOR_FONDO      <- "#FFFFFF"   # fondo de la página
COLOR_TEXTO      <- "#2E0A4E"   # color de las letras
COLOR_NAVEGACION <- "#2E0A4E"   # barra de navegación de arriba

# Tipografías. Cualquier nombre de https://fonts.google.com funciona.
FUENTE_TEXTO   <- "Inter"
FUENTE_TITULOS <- "Oswald"

# Tema prearmado (nuevo). NULL usa los colores y fuentes de arriba.
# Si ponés un nombre, la app toma ese tema completo y se ignora lo de arriba.
# Es la versión actual de {shinythemes}. Probá "flatly", "minty", "darkly",
# "journal", "sketchy" o "united". La lista completa sale con bootswatch_themes().
TEMA_BOOTSWATCH <- NULL

# Filas que muestra la tabla en cada página
FILAS_POR_PAGINA <- 10

# Fin de la ZONA DE PRUEBAS ==============================
################################################################################



# ESTÉTICA (Clase 7)
# Con TEMA_BOOTSWATCH en NULL se usa el tema del curso. Si no, el prearmado.
if (is.null(TEMA_BOOTSWATCH)) {
  tema_curso <- bs_theme(
    version = 5, bg = COLOR_FONDO, fg = COLOR_TEXTO,
    primary = COLOR_PRINCIPAL, secondary = COLOR_SECUNDARIO,
    base_font    = font_google(FUENTE_TEXTO,   local = FALSE),
    heading_font = font_google(FUENTE_TITULOS, local = FALSE),
    "navbar-bg"  = COLOR_NAVEGACION
  )
} else {
  tema_curso <- bs_theme(version = 5, bootswatch = TEMA_BOOTSWATCH)
}

################################################################################

# CODIGO ESTATICO

# Un corpus de ejemplo, para que la app funcione antes de subir nada.
ejemplo <- read.csv("../datos/elecciones_departamento_2024.csv", encoding = "UTF-8")

# fileInput() acepta archivos de hasta 5 MB por defecto. Lo subimos a 30 MB.
options(shiny.maxRequestSize = 30 * 1024^2)




################################################################################
# INTERFAZ (UI)

# Pieza A. La barra lateral, con los controles del programa que faltaban.
barra <- sidebar(
  title = "Tu corpus",

  # 1) fileInput(). Un botón para subir un archivo desde la computadora.
  fileInput("archivo", "Subí un archivo CSV:", accept = ".csv",
            buttonLabel = "Buscar", placeholder = "Ningún archivo"),

  # 2) radioButtons(). Una sola opción entre varias.
  # Excel en español guarda los CSV separados por punto y coma.
  radioButtons("separador", "Separador de columnas:",
               choices = c("Coma" = ",", "Punto y coma" = ";"), inline = TRUE),

  # 3) textInput() y dateInput(). Texto libre y un calendario.
  textInput("proyecto", "Nombre del proyecto:", value = "mi_corpus"),
  dateInput("fecha", "Fecha de la revisión:", format = "dd/mm/yyyy", language = "es"),

  # 4) downloadButton(). Descarga los datos tal como los leyó la app.
  downloadButton("descargar", "Descargar CSV revisado", class = "btn-primary"),

  p("Sin archivo, la app muestra un corpus de ejemplo (Elección Nacional 2024).")
)

# Pieza B. Tres cajas con el tamaño del corpus.
numeros <- layout_columns(
  value_box("Filas",          textOutput("n_filas"),    showcase = icon("bars"),  theme = "primary"),
  value_box("Columnas",       textOutput("n_columnas"), showcase = icon("table-columns"), theme = "primary"),
  value_box("Celdas vacías",  textOutput("n_vacias"),   showcase = icon("circle-question"), theme = "primary")
)

ui <- page_navbar(
  title    = TITULO,
  theme    = tema_curso,
  sidebar  = barra,
  fillable = FALSE,
  navbar_options = navbar_options(theme = "dark"),

  nav_panel("Resumen",
            numeros,
            card(card_header("Celdas vacías por columna"),
                 plotOutput("g_vacias", height = "400px"))),

  nav_panel("Datos",
            card(card_header("Tus datos, tal como los leyó R"),
                 DTOutput("tabla", fill = FALSE))),

  nav_panel("Estructura",
            card(card_header("Qué tipo de dato es cada columna"),
                 p("int y num son números, chr es texto, logi es verdadero o falso."),
                 verbatimTextOutput("estructura")),
            card(card_header("Resumen de cada columna"),
                 verbatimTextOutput("resumen"))),

  nav_panel("Checklist",
            card(card_header("Antes de programar tu app, revisá que tu corpus tenga"),
                 tags$ul(
                   tags$li("Al menos una columna de texto para filtrar y una numérica para graficar."),
                   tags$li("Una fila por observación, sin celdas combinadas ni filas de totales."),
                   tags$li("Una fuente identificable y citable."),
                   tags$li("Si va a tener mapa, columnas de latitud y longitud."),
                   tags$li("Un tamaño razonable para publicar (menos de 20 MB).")
                 )))
)



################################################################################
# SERVIDOR (SERVER)


server <- function(input, output, session) {

  # Los datos. Si no se subió nada, usamos el ejemplo.
  # input$archivo es NULL hasta que se sube un archivo. Cuando se sube,
  # input$archivo$datapath dice dónde lo guardó Shiny.
  datos <- reactive({
    # read.csv2() es read.csv() para los archivos de Excel en español, que
    # separan con punto y coma y usan coma decimal (1,5 en lugar de 1.5).
    # try() intenta leer y, si falla, guarda el error en lugar de cortar la app.
    if (is.null(input$archivo)) {
      d <- ejemplo
    } else if (input$separador == ";") {
      d <- try(read.csv2(input$archivo$datapath, encoding = "UTF-8"), silent = TRUE)
    } else {
      d <- try(read.csv(input$archivo$datapath, encoding = "UTF-8"), silent = TRUE)
    }

    # validate() y need(). Si la condición es FALSE, en lugar de un error rojo
    # todos los outputs muestran este mensaje.
    validate(need(is.data.frame(d),
                  "No se pudo leer. Probá el otro separador."))
    validate(need(ncol(d) > 1,
                  "Una sola columna. Probá el otro separador."))
    validate(need(nrow(d) > 0, "El archivo no tiene filas."))

    # Para depurar. print() escribe en la consola de RStudio cada vez que
    # se recalcula. Sacale el # para probarlo. browser() frena la app acá
    # y te deja inspeccionar d en la consola.
    # print(dim(d))
    # browser()

    d
  })

  output$n_filas <- renderText({
    nrow(datos())
  })

  output$n_columnas <- renderText({
    ncol(datos())
  })

  output$n_vacias <- renderText({
    sum(is.na(datos()))
  })

  # colSums(is.na(d)) cuenta las celdas vacías de cada columna.
  # alt = describe el gráfico para quienes usan lectores de pantalla.
  output$g_vacias <- renderPlot({
    vacias <- colSums(is.na(datos()))
    # validate() también sirve para mensajes buenos.
    validate(need(sum(vacias) > 0, "No hay celdas vacías. Buena señal."))
    par(mar = c(4, 12, 1, 1))
    barplot(vacias, horiz = TRUE, las = 1, col = COLOR_PRINCIPAL, border = NA,
            xlab = "Celdas vacías", cex.names = 0.8)
  }, alt = "Gráfico de barras con la cantidad de celdas vacías en cada columna del corpus")

  output$tabla <- renderDT({
    datatable(datos(), rownames = FALSE,
              options = list(pageLength = FILAS_POR_PAGINA,
                             language = list(url = "https://cdn.datatables.net/plug-ins/1.13.6/i18n/es-ES.json")))
  })

  output$estructura <- renderPrint({
    str(datos())
  })

  output$resumen <- renderPrint({
    summary(datos())
  })

  # downloadHandler() tiene dos partes.
  #   filename  el nombre del archivo, armado con el proyecto y la fecha
  #   content   cómo escribirlo
  output$descargar <- downloadHandler(
    filename = function() {
      paste0(input$proyecto, "_", input$fecha, ".csv")
    },
    content = function(archivo) {
      write.csv(datos(), archivo, row.names = FALSE, fileEncoding = "UTF-8")
    }
  )
}

################################################################################
# ARRANCAR LA APP
shinyApp(ui = ui, server = server)
