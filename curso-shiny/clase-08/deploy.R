# =============================================================================
# deploy.R — Publicar la app en shinyapps.io (Clase 8)
# -----------------------------------------------------------------------------
# Pasos (una sola vez):
#   1) Crear una cuenta gratuita en https://www.shinyapps.io/
#   2) En la web: Account -> Tokens -> "Show" -> copiar el bloque
#      rsconnect::setAccountInfo(...) y pegarlo/ejecutarlo UNA vez en R.
#   3) install.packages("rsconnect")
#
# IMPORTANTE: los datos deben viajar con la app. Este proyecto incluye una
# copia del CSV en clase-08/datos/ para que el deploy funcione. rsconnect
# sube automáticamente todos los archivos de la carpeta de la app.
# =============================================================================

# install.packages("rsconnect")
library(rsconnect)

# Pegá acá tus credenciales (las obtenés en shinyapps.io -> Account -> Tokens):
# rsconnect::setAccountInfo(
#   name   = "TU_USUARIO",
#   token  = "TU_TOKEN",
#   secret = "TU_SECRET"
# )

# Publicar la app (ejecutar parado en la carpeta clase-08/):
rsconnect::deployApp(
  appDir  = ".",
  appName = "censo-uruguay-2023",
  appTitle = "Tablero Censo 2023 - Uruguay"
)

# Al terminar, R abre la URL pública, del tipo:
#   https://TU_USUARIO.shinyapps.io/censo-uruguay-2023/
