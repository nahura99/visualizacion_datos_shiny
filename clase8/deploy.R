# =============================================================================
# PUBLICAR LA APP EN shinyapps.io · Clase 8
#
# =============================================================================

# Una sola vez
#   1) Crear una cuenta gratuita en https://www.shinyapps.io
#   2) Instalar el paquete que publica
install.packages("rsconnect")
#   3) En shinyapps.io ir a Account, después Tokens, apretar "Show" y copiar
#      la línea rsconnect::setAccountInfo(...). Pegarla abajo y correrla.
# rsconnect::setAccountInfo(name = "TU_USUARIO", token = "TU_TOKEN", secret = "TU_SECRET")

################################################################################

# Antes de publicar
#   - En app.R cambiar options(shiny.sanitize.errors = FALSE) por TRUE.
#   - Revisar que la carpeta datos/ esté al lado de app.R. Todo lo que está en
#     esta carpeta viaja con la app.

################################################################################

# Publicar. Correr este archivo parado en la carpeta clase8.
rsconnect::deployApp(appName = "elecciones-uruguay-2024")

# Al terminar se abre la dirección pública, que tiene esta forma
#   https://TU_USUARIO.shinyapps.io/elecciones-uruguay-2024/
#
# Si la app muestra una pantalla gris, mirar qué falló con
rsconnect::showLogs()
