***Visualización interactiva de datos con R y Shiny***

Este repositorio reúne los materiales del curso _Visualización interactiva de datos con R y Shiny_, que se dicta en el marco de Educación Permanente de la Facultad de Ciencias Sociales (Universidad de la República) desde la Unidad de Métodos y Acceso a Datos. El objetivo es que cualquier persona que trabaje con datos, aunque no tenga experiencia previa en programación, pueda construir y publicar un tablero web interactivo usando R y el paquete Shiny.

| Carpeta | Tema | Qué se construye |
|---|---|---|
| Clase 1 | Presentación del curso | Presentación, programas y ejemplos de apps Shiny publicadas. |
| Clase 1b | Opcional - Nivelación en R | Instalar R y RStudio, lo básico de R y la primera app de Shiny. |
| Clase 2 | Bases de RStudio,Shiny | Un menú que cambia un texto y una tabla fija. |
| Clase 3 | UI - Interfaz de Usuario | Barra lateral, filas, columnas y pestañas. |
| Clase 4 | Inputs y outputs | Filtros, gráfico de barras, tabla y textos. |
| Clase 5 | Reactividad | El filtro escrito una sola vez y un botón para aplicarlo. |
| Clase 6 | Gráficos dinámicos | Gráficos con ggplot2 y uno interactivo con plotly. |
| Clase 7 | Estética, navegación | Barra de navegación, cajas de números, tarjetas y tabla interactiva. |
| Clase 8 | App final. Publicación | Gráficos, tablas y mapas en tres paneles, publicados en shinyapps.io. |

El curso está pensado como un taller y se apoya en una sola aplicación que crece de clase en clase. En la primera sesión la app es apenas un título y una tabla. En la última es un tablero completo con gráficos, tablas y mapas, publicado en internet. Cada clase suma un paso concreto y visible sobre la anterior, de modo que quien sigue el recorrido puede ver en pantalla qué cambió y ubicar en el código la parte que produjo ese cambio. El código se mantiene deliberadamente sencillo y todo lo que aparece se explica en clase.

Los datos de trabajo son los resultados de la Elección Nacional 2024 de Uruguay, publicados por la Corte Electoral, agregados por departamento y por local de votación. Se complementan con la población por departamento de los Censos 2011 y 2023 del Instituto Nacional de Estadística. Están en la carpeta datos, que tiene su propio archivo de documentación con el detalle de cada columna y de cómo se construyó cada tabla.

Cada carpeta de clase contiene un archivo app.R y una presentación con la misma estética en todo el curso. Todas las apps comparten una estructura fija, con una sección de librerías, una de código estático, la interfaz, el servidor y el arranque de la app, cada una separada y comentada. Al comienzo de cada app.R hay una zona de pruebas, un bloque de variables en mayúscula (colores, tipografías, disposición de la pantalla, formato de las tablas y de los gráficos) que se puede modificar para ver cómo el código transforma la app. La zona se va ampliando a medida que avanza el curso.

El recorrido tiene diez clases. La Clase 0 prepara el terreno, con la instalación de R y RStudio, lo básico del lenguaje y la primera app de Shiny. La Clase 1 presenta el curso y muestra ejemplos de tableros publicados. De la Clase 2 a la 8 se recorren los temas del programa, en este orden. La arquitectura básica de una app. El diseño de la interfaz. Las entradas y salidas. El motor reactivo. Los gráficos con ggplot2 y plotly. La estética y la navegación con bslib. Por último, la app final de tres paneles con mapas de leaflet y su publicación en shinyapps.io. La última clase, en la carpeta revisor_corpus, trabaja sobre los datos propios de cada participante, completa los contenidos del programa que quedaban pendientes y discute los límites y las potencialidades de Shiny.

Para usar el repositorio hace falta tener instalados R y RStudio, y los paquetes shiny, bslib, ggplot2, plotly, DT, leaflet y rsconnect. Conviene abrir siempre el archivo visualizacion_datos_shiny.Rproj, para que RStudio trabaje desde la carpeta del curso. Para correr cualquier clase alcanza con abrir su app.R y apretar el botón Run App. Las apps leen los datos desde la carpeta compartida con la ruta ../datos/, excepto la de la Clase 8, que lleva su propia copia porque es la que se publica.
