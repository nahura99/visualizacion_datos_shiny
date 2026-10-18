# =============================================================================
# CLASE 1 · Primeros pasos con R y RStudio
#
# Este archivo NO es una app. Es un guion para correr de a una línea.
# Poné el cursor en una línea y apretá Ctrl + Enter (Cmd + Enter en Mac).
# El resultado aparece abajo, en la consola.
# =============================================================================


################################################################################
# 0) ANTES DE EMPEZAR

# 1. Instalar R desde https://cran.r-project.org (la versión más reciente).
# 2. Instalar RStudio Desktop desde https://posit.co/download/rstudio-desktop
# 3. Abrir el archivo visualizacion_datos_shiny.Rproj con doble clic.
#    Así RStudio abre el PROYECTO del curso y sabe dónde están los datos.
#    Un proyecto es una carpeta con un archivo .Rproj. Mientras está abierto,
#    R trabaja desde esa carpeta. Su nombre aparece arriba a la derecha de
#    RStudio. Si no aparece, File, Open Project y elegir el archivo .Rproj.
# 4. Desde el panel de archivos (abajo a la derecha) abrir clase1/primeros_pasos.R

# Todo lo que empieza con # es un COMENTARIO. R no lo ejecuta. Sirve para
# explicar el código a quien lo lea, incluso a vos dentro de un mes.


################################################################################
# 1) LA CONSOLA COMO CALCULADORA

2 + 2
10 * 3
100 / 7


################################################################################
# 2) OBJETOS
# Con <- guardamos un valor con un nombre. Se lee "recibe".
# Después aparece en el panel Environment (arriba a la derecha).

habilitados <- 2727120
emitidos    <- 2443801

emitidos / habilitados * 100     # la participación, en %

# Un objeto también puede guardar texto, siempre entre comillas.
pais <- "Uruguay"
pais


################################################################################
# 3) VECTORES
# c() junta varios valores en un solo objeto. Todos del mismo tipo.

departamentos <- c("Montevideo", "Canelones", "Maldonado")
votos         <- c(906749, 389098, 138362)

departamentos
votos
votos[1]              # el primero, entre corchetes


################################################################################
# 4) FUNCIONES
# Una función recibe algo entre paréntesis y devuelve un resultado.

sum(votos)            # suma
mean(votos)           # promedio
length(votos)         # cuántos valores hay
round(mean(votos))    # una función adentro de otra

# paste0() pega textos. Lo vamos a usar mucho en las apps.
paste0("En ", pais, " votaron ", emitidos, " personas.")

# Para ver la ayuda de cualquier función, un signo de pregunta adelante.
?mean


################################################################################
# 5) PAQUETES
# Un paquete suma funciones nuevas a R. Shiny es un paquete.

# Se instala UNA sola vez por computadora. Sacale el # y corré la línea.
# install.packages(c("shiny", "bslib", "ggplot2", "plotly", "DT", "leaflet", "rsconnect"))

# Si ya tenías R instalado de antes, actualizá TODOS los paquetes. Un paquete
# viejo puede no llevarse bien con uno nuevo (por ejemplo, un plotly viejo con
# un ggplot2 nuevo da error en los gráficos interactivos). Sacale el # y corré
# la línea. Si pregunta si querés instalar "from sources", respondé n (no).
# update.packages(ask = FALSE)

# Después de instalar o actualizar, reiniciá R: menú Session, Restart R.

# Se activa con library() cada vez que abrís R.
library(shiny)


################################################################################
# 6) LEER DATOS
# getwd() dice en qué carpeta está trabajando R. Con el proyecto abierto,
# es la carpeta del curso, así que los datos están en "datos/".

getwd()

elecciones <- read.csv("datos/elecciones_departamento_2024.csv", encoding = "UTF-8")

# ¿Por qué las apps del curso usan "../datos/"? Porque cuando apretás Run App,
# R se para en la carpeta de la clase (por ejemplo clase2/), y ".." quiere
# decir "subí una carpeta". Desde ahí, datos/ está un nivel más arriba.


################################################################################
# 7) MIRAR LOS DATOS
# elecciones es un DATA FRAME, una tabla con filas y columnas, como Excel.

head(elecciones)      # las primeras 6 filas
nrow(elecciones)      # cuántas filas (19 departamentos)
ncol(elecciones)      # cuántas columnas
names(elecciones)     # los nombres de las columnas
View(elecciones)      # la abre como planilla, en una pestaña nueva


################################################################################
# 8) ELEGIR COLUMNAS Y FILAS

# Con $ elegimos una columna. Devuelve un vector.
elecciones$departamento
sum(elecciones$emitidos)

# Con [filas, columnas] elegimos un pedazo. Vacío quiere decir "todas".
elecciones[1, ]                                    # la fila 1
elecciones[, c("departamento", "emitidos")]        # dos columnas
elecciones[elecciones$region == "Norte", ]         # las filas del Norte

# == pregunta "¿es igual a?". Un solo = sirve para otra cosa, ojo.


################################################################################
# 9) UN GRÁFICO RÁPIDO
# R dibuja en el panel Plots (abajo a la derecha).

barplot(elecciones$emitidos, names.arg = elecciones$departamento, las = 2)


################################################################################
# 10) Y AHORA, SHINY
# Abrí clase1/app.R y apretá el botón "Run App" (arriba del script).
# Para cerrar la app, apretá el botón rojo de STOP en la consola o Esc.


################################################################################
# 11) DESAFÍO OPCIONAL, TU REPOSITORIO EN GITHUB
# Este paso es OPCIONAL. El curso se puede hacer completo sin GitHub.
# Git guarda versiones de tu código y GitHub las guarda en la web. Así podés
# volver a una versión anterior, trabajar desde otra computadora y mostrar
# tus apps.

# Una sola vez
# 1. Crear una cuenta gratuita en https://github.com
# 2. Instalar Git desde https://git-scm.com (en Mac alcanza con escribir
#    git --version en la Terminal y aceptar). Después reiniciar RStudio.
# 3. Decirle a Git quién sos. Sacale el # a las dos líneas, poné tus datos
#    y corrélas.
# system('git config --global user.name "Tu Nombre"')
# system('git config --global user.email "tu_correo@ejemplo.com"')
# 4. En GitHub, New repository. Ponerle un nombre (por ejemplo mi_curso_shiny),
#    marcar Add README y crearlo. Copiar la dirección del botón verde Code.
# 5. En RStudio, File, New Project, Version Control, Git. Pegar la dirección,
#    elegir dónde guardarlo y apretar Create Project. Tu repositorio queda
#    abierto como un PROYECTO, con su propio .Rproj, igual que el del curso.

# En cada clase
# 6. Copiar a tu proyecto la carpeta datos/ y la carpeta de la clase en la
#    que vas a trabajar (por ejemplo clase1/). Hacé tus cambios ahí. Así la
#    ruta ../datos/ sigue funcionando.
# 7. En la pestaña Git (arriba a la derecha) marcar los archivos en Staged,
#    apretar Commit, escribir un mensaje corto y apretar Commit otra vez.
# 8. Apretar Push. La nueva versión queda guardada en GitHub.

# Para volver al curso, File, Open Project y elegir visualizacion_datos_shiny.Rproj.
# Cada proyecto es una carpeta distinta.
