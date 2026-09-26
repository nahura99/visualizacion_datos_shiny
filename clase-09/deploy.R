# =============================================================================
# deploy.R · Publicar la app final en shinyapps.io (Clase 9)
# -----------------------------------------------------------------------------
# Pasos (una sola vez):
#   1) Crear una cuenta gratuita en https://www.shinyapps.io/
#   2) En la web: Account -> Tokens -> "Show" -> copiar el bloque
#      rsconnect::setAccountInfo(...) y ejecutarlo UNA vez en la consola de R.
#   3) install.packages("rsconnect")
#
# IMPORTANTE: los datos deben viajar con la app. Esta carpeta incluye una
# copia de los tres CSV en clase-09/datos/ para que el deploy funcione.
# rsconnect sube todos los archivos de la carpeta de la app.
#
# Antes de publicar, en app.R poné: options(shiny.sanitize.errors = TRUE)
# =============================================================================

library(rsconnect)

# Pegá acá tus credenciales (shinyapps.io -> Account -> Tokens) y ejecutalo una vez:
# rsconnect::setAccountInfo(name = "TU_USUARIO", token = "TU_TOKEN", secret = "TU_SECRET")

# Publicar (ejecutar parado en la carpeta clase-09/):
rsconnect::deployApp(
  appDir   = ".",
  appName  = "elecciones-uruguay-2024",
  appTitle = "Elecciones Nacionales 2024 - Uruguay",
  appFiles = c("app.R", "datos/elecciones_departamento_2024.csv",
               "datos/elecciones_locales_2024.csv", "datos/elecciones_circuitos_2024.csv")
)

# Al terminar, R abre la URL pública:
#   https://TU_USUARIO.shinyapps.io/elecciones-uruguay-2024/
#
# Si algo falla:  rsconnect::showLogs()
