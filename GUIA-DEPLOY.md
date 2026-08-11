# Guía de despliegue en shinyapps.io

Publicar una app Shiny en la nube de Posit (shinyapps.io) es gratis para proyectos chicos y no requiere servidor propio.

## 1. Crear la cuenta y conectar R (una sola vez)

1. Registrate en https://www.shinyapps.io/ (podés entrar con tu cuenta de Google o GitHub).
2. Instalá el paquete en R: `install.packages("rsconnect")`.
3. En la web de shinyapps.io: **Account → Tokens → Show**. Vas a ver un bloque como este; copialo y ejecutalo **una vez** en la consola de R:

```r
rsconnect::setAccountInfo(
  name   = "TU_USUARIO",
  token  = "xxxxxxxxxxxxxxxx",
  secret = "yyyyyyyyyyyyyyyy"
)
```

## 2. Publicar una app

Cada app se publica desde su propia carpeta. Importante: **los datos deben viajar con la app**, así que el CSV tiene que estar dentro de la carpeta que subís. En este repo, la Clase 8 ya incluye su copia en `clase-08/datos/`.

```r
library(rsconnect)
# parado en la carpeta de la app (por ejemplo clase-08/ o hub/):
rsconnect::deployApp(appName = "censo-uruguay-2023")
```

Al terminar, R abre la URL pública: `https://TU_USUARIO.shinyapps.io/censo-uruguay-2023/`.

## 3. Publicar el hub

El hub (`hub/app.R`) es la portada del curso. Antes de publicarlo, editá las tres primeras variables del archivo (`usuario_github`, `repo_github`, `usuario_shiny`) con tus datos, y luego:

```r
setwd("hub")
rsconnect::deployApp(appName = "curso-shiny")
```

## Errores comunes

- **"cannot open file ...csv"**: el CSV no está dentro de la carpeta de la app. Copiálo a `datos/` dentro de esa carpeta.
- **La app queda gris al abrir**: revisá los logs con `rsconnect::showLogs()`.
- **Falta un paquete**: shinyapps.io instala automáticamente los paquetes que tu app carga con `library()`. Asegurate de que estén todos declarados.
- **Se agotaron las horas gratis**: el plan free tiene un tope mensual de horas activas; si lo superás, la app se pausa hasta el mes siguiente.
