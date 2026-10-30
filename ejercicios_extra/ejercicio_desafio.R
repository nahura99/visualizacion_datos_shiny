# =============================================================================
# EJERCICIO EXTRA - Desafío, una app rota para arreglar
# Para quienes ya se manejan con R. Una app que cruza el padrón electoral con
# el censo, pero tiene seis errores. Hay que encontrarlos, arreglarlos y
# después hacer la app propia.

################################################################################
#RUTA A LOS DATOS
# La app lee las tablas de la carpeta datos/. Antes de empezar, revisá que la
# ruta de abajo lleve a esa carpeta.
#
#   - Si está en ejercicios_extra/, dentro de la carpeta del curso, datos/
#     queda un nivel más arriba. Por eso la ruta empieza con "../"
#   - Si lo guardaste en otro lado, poné la ruta a tu carpeta datos, con
#     barras / y una barra al final. Por ejemplo
#     "C:/Users/tu_usuario/Documents/curso_shiny/datos/"
# Si la ruta está mal, al apretar Run App aparece un error

RUTA_DATOS <- "../datos/"


################################################################################
# CÓMO SEGUIR
#
# La pregunta de la app es cuántas personas habilitadas para votar hay en cada
# departamento por cada 100 personas que viven ahí (Censo 2023).
#
# Tiene 6 ERRORES, marcados con un comentario # ERROR n. La marca está en el
# bloque del error, no siempre en la línea exacta.
#
#   - Los errores 1, 2, 4 y 5 no dejan arrancar la app. Apretá Run App, leé el
#     mensaje rojo de la consola y buscá a cuál corresponde.
#   - Los errores 3 y 6 no dan ningún mensaje. La app arranca, pero un número
#     no tiene sentido o algo no aparece. Son los más difíciles.
#
# Ojo, no van a aparecer en orden. R primero lee TODO el script para ver si
# está bien escrito (una coma de menos, un signo equivocado) y recién después
# lo corre de arriba hacia abajo. Por eso el primer error que vas a ver no es
# el 1.
#
# Cuando la app ande, seguí con las consignas PERSONALIZAR (A a D).

library(shiny)
library(bslib)


################################################################################
## ZONA DE PRUEBAS

# PERSONALIZAR A
# Poné un título que diga de qué se trata la app y elegí tus colores. Sirven
# nombres de colores de R ("tomato", "steelblue") o códigos como "#2A9D8F".
# Cambiá también la región con la que arranca el menú.
TITULO          <- "Mi app"
COLOR_PRINCIPAL <- "#5A189A"
COLOR_FONDO     <- "#FFFFFF"
COLOR_TEXTO     <- "#2E0A4E"
COLOR_BARRAS    <- "grey60"
REGION_INICIAL  <- "Metropolitana"   # Centro, Este, Litoral, Metropolitana o Norte

################################################################################

tema <- bs_theme(version = 5, bg = COLOR_FONDO, fg = COLOR_TEXTO,
                 primary = COLOR_PRINCIPAL)

# CODIGO ESTATICO
# Dos tablas con una fila por departamento.
elecciones <- read.csv(paste0(RUTA_DATOS, "elecciones_departamento_2024.csv"), encoding = "UTF-8")

# ERROR 1
censo <- read.csv(paste0(RUTA_DATOS, "censo_departamento.csv"), encoding = "UTF-8")

# Del censo nos quedamos con dos columnas. Si traemos todas, la columna region
# aparece dos veces, porque está en las dos tablas.
censo <- censo[, c("departamento", "poblacion_2023")]

# merge() junta las dos tablas en una sola, emparejando las filas por la
# columna que se indica en by.
# ERROR 2
datos <- merge(elecciones, censo, by = "Departamento")

# Una columna nueva, cuántas personas habilitadas hay cada 100 habitantes.
# ERROR 3
datos$hab_cada_100 <- round(datos$habilitados / datos$poblacion_2023 / 100, 1)

# Las cinco regiones, para el menú.
regiones <- sort(unique(datos$region))


################################################################################
# INTERFAZ (UI)

ui <- fluidPage(
  theme = tema,
  titlePanel(TITULO),
  p("Personas habilitadas para votar (Elección Nacional 2024, Corte Electoral)
    y población (Censo 2023, INE), por departamento."),

  # Un INPUT, un menú desplegable. El valor elegido le llega al server como
  # input$region. Hoy en la clase lo vemos en detalle.
  selectInput("region", "Elegí una región:", choices = regiones,
              selected = REGION_INICIAL),

  textOutput("resumen"),

  # ERROR 4
  h3("Habilitados cada 100 habitantes")
  plotOutput("grafico"),

  h3("Los números"),
  tableOutput("tabla")
)


################################################################################
# SERVIDOR (SERVER)

server <- function(input, output, session) {

  # renderPlot() dibuja un gráfico de R base en el plotOutput("grafico").
  output$grafico <- renderPlot({
    datos_region <- datos[datos$region == input$region, ]

    # PERSONALIZAR B
    # Ordená las barras de mayor a menor (order() ya lo vimos en la clase 1).
    # Más difícil, sumá una línea horizontal con el valor de todo el país,
    # usando abline(h = ...) abajo del barplot().
    barplot(datos_region$hab_cada_100, names.arg = datos_region$departamento,
            col = COLOR_BARRAS, ylim = c(0, 100), las = 2)
  })

  output$tabla <- renderTable({
    # ERROR 5
    datos_region <- datos[datos$region = input$region, ]

    # PERSONALIZAR C
    # Sumá la columna participacion_pct y cambiale los nombres a las columnas
    # para que se lean mejor, con names(). Por ejemplo "Población 2023".
    datos_region[, c("departamento", "habilitados", "poblacion_2023", "hab_cada_100")]
  }, digits = 1)

  # ERROR 6
  output$resume <- renderText({
    datos_region <- datos[datos$region == input$region, ]
    # which.max() dice en qué fila está el valor más alto.
    fila <- datos_region[which.max(datos_region$hab_cada_100), ]

    # PERSONALIZAR D
    # Sumale una frase al texto. Por ejemplo, el departamento con el valor
    # más bajo de la región (existe which.min()).
    paste0("En la región ", input$region, ", el departamento con más habilitados ",
           "cada 100 habitantes es ", fila$departamento, " (", fila$hab_cada_100, ").")
  })
}


################################################################################
# ARRANCAR LA APP
shinyApp(ui = ui, server = server)


################################################################################
# PARA PENSAR, cuando todo ande
# Elegí Metropolitana y después Centro. ¿Por qué Canelones queda tan abajo y
# Flores tan arriba? Una pista está en la columna variacion_pct del censo.
