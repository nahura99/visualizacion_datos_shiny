# =============================================================================
# HUB DEL CURSO — Shiny desplegable que enlaza las 10 clases
# Curso: Visualización interactiva de datos con R y Shiny (Udelar)
# -----------------------------------------------------------------------------
# Esta es la app "portada" del curso. Muestra las 10 clases con la estética
# violeta del curso y enlaza cada una a su carpeta en GitHub y a su app.
#
# CONFIGURACIÓN: reemplazá estos dos valores por los tuyos y listo.
# =============================================================================

library(shiny)
library(bslib)

usuario_github <- "TU_USUARIO"        # <- tu usuario de GitHub
repo_github    <- "curso-shiny"       # <- nombre del repositorio
usuario_shiny  <- "TU_USUARIO"        # <- tu usuario de shinyapps.io

base_repo  <- sprintf("https://github.com/%s/%s/tree/main", usuario_github, repo_github)
base_shiny <- sprintf("https://%s.shinyapps.io", usuario_shiny)

# --- Contenido de las 10 clases ---------------------------------------------
clases <- list(
  list(n = 1,  t = "Bases de RStudio y Shiny",  d = "Arquitectura UI-server. Código estático vs. reactivo."),
  list(n = 2,  t = "Interfaz de Usuario (UI)",   d = "Layouts, paneles, títulos y etiquetas."),
  list(n = 3,  t = "Entradas de Datos (Inputs)", d = "Sliders, menús, calendarios y cajas de texto."),
  list(n = 4,  t = "Salidas (Outputs)",          d = "Funciones render*: tablas y textos que se actualizan."),
  list(n = 5,  t = "El Motor Reactivo",          d = "reactive(), req() y manejo de errores."),
  list(n = 6,  t = "Gráficos Dinámicos",         d = "ggplot2 reactivo: barras y dispersión."),
  list(n = 7,  t = "Estética y Navegación",      d = "Temas con bslib, pestañas y cards."),
  list(n = 8,  t = "Puesta en Producción",       d = "App integrada, descargas y deploy a shinyapps.io."),
  list(n = 9,  t = "Trabajo Final (I)",          d = "Plantilla para tu propia Shiny con tus datos."),
  list(n = 10, t = "Trabajo Final (II)",         d = "Módulos, cierre, deploy y presentación.")
)

# --- Estética violeta del curso ("aesthetics") ------------------------------
morado_profundo <- "#2E0A4E"
morado          <- "#5A189A"
morado_claro    <- "#9D4EDD"
acento          <- "#C77DFF"

css <- sprintf("
  body { background-color: %s; }
  .hero { color: #fff; padding: 48px 24px 8px 24px; }
  .hero h1 { font-family: 'Oswald', sans-serif; font-weight: 700;
             letter-spacing: .5px; font-size: 2.4rem; }
  .hero p  { color: %s; font-size: 1.1rem; max-width: 720px; }
  .clase-card { background:#fff; border-radius:14px; padding:20px;
                height:100%%; box-shadow: 0 6px 18px rgba(0,0,0,.25); }
  .clase-num { font-family:'Oswald',sans-serif; font-weight:700; color:%s;
               font-size: 1.6rem; }
  .clase-card h5 { font-family:'Oswald',sans-serif; color:%s; margin-top:2px; }
  .clase-card p { color:#333; font-size:.92rem; min-height:48px; }
  .btn-clase { background:%s; color:#fff; border:none; }
  .btn-clase:hover { background:%s; color:#fff; }
  .btn-out { border:1px solid %s; color:%s; }
  footer { color:%s; padding:24px; text-align:center; }
", morado_profundo, acento, morado_claro, morado, morado, morado_profundo,
   morado, morado, acento)

# --- Una tarjeta por clase --------------------------------------------------
tarjeta_clase <- function(c) {
  carpeta <- sprintf("%s/clase-%02d", base_repo, c$n)
  app_url <- sprintf("%s/clase-%02d-shiny", base_shiny, c$n)  # opcional
  div(class = "clase-card",
      div(class = "clase-num", sprintf("Clase %02d", c$n)),
      h5(c$t),
      p(c$d),
      div(
        tags$a(href = carpeta, target = "_blank",
               class = "btn btn-sm btn-clase", "Código en GitHub"),
        " ",
        tags$a(href = app_url, target = "_blank",
               class = "btn btn-sm btn-out", "Ver app")
      )
  )
}

ui <- page_fluid(
  theme = bs_theme(version = 5, base_font = font_google("Inter"),
                   heading_font = font_google("Oswald")),
  tags$head(tags$style(HTML(css)),
            tags$link(rel = "preconnect", href = "https://fonts.googleapis.com")),

  div(class = "hero",
      h1("Visualización interactiva de datos con R y Shiny"),
      p("Curso de Educación Permanente · Universidad de la República."),
      p("Diez clases que construyen, paso a paso, una aplicación Shiny compleja. ",
        "Cada clase incluye una app de ejemplo para replicar y su código en GitHub.")
  ),

  div(style = "padding: 8px 24px 24px 24px;",
      do.call(layout_column_wrap,
              c(list(width = 1/2), lapply(clases, tarjeta_clase)))
  ),

  tags$footer(
    HTML(sprintf("Repositorio: <a style='color:%s' href='%s' target='_blank'>%s/%s</a> · Bibliografía: Wickham (2021), Sievert (2020), Beeley (2018).",
                 acento, sprintf("https://github.com/%s/%s", usuario_github, repo_github),
                 usuario_github, repo_github))
  )
)

server <- function(input, output, session) {}

shinyApp(ui, server)
