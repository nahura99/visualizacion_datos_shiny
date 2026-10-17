# =============================================================================
# PUBLICAR LA APP EN POSIT CONNECT CLOUD · Clase 7
#
# =============================================================================

# Una sola vez
#   1) Crear una cuenta gratuita en https://connect.posit.cloud
#   2) Instalar o actualizar el paquete que publica
install.packages("rsconnect")
#   3) Conectar R con tu cuenta. Se abre el navegador para autorizar.
rsconnect::connectCloudUser()
#   4) Revisar que la cuenta quedó conectada
rsconnect::accounts()

################################################################################

# Antes de publicar
#   - En app.R cambiar options(shiny.sanitize.errors = FALSE) por TRUE.
#   - Revisar que la carpeta datos/ esté al lado de app.R. Todo lo que está en
#     esta carpeta viaja con la app.

################################################################################

# Publicar. Con el proyecto abierto, R está en la carpeta del curso, y appDir
# le dice qué carpeta publicar.
rsconnect::deployApp(appDir  = "clase7",
                     appName = "elecciones-uruguay-2024")

# Al terminar se abre la app en Posit Connect Cloud. La dirección tiene esta forma
#   https://connect.posit.cloud/TU_USUARIO/content/...
# Para publicar una versión nueva, corré otra vez deployApp().
#
# Si la app muestra una pantalla gris, entrá a su página en Posit Connect Cloud.
# El ícono Logs, a la derecha, muestra qué falló.

################################################################################

# Desafío opcional. Si llevás tu repositorio de GitHub, guardá también esta
# versión con Commit y Push, como en la Clase 1.
