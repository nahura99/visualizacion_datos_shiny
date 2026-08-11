# Visualización interactiva de datos con R y Shiny

Curso de Educación Permanente · Universidad de la República (Udelar).

Este repositorio acompaña un curso de 10 clases (2 horas cada una) para aprender **Shiny desde cero**. Las clases están pensadas como una escalera: cada una agrega una pieza hasta llegar, en la Clase 8, a una aplicación Shiny compleja y desplegada. Las dos últimas clases se dedican al trabajo final, donde cada participante construye su propia Shiny sobre un tema de su interés.

Todas las clases incluyen una **app de ejemplo en código para replicar** (`clase-XX/app.R`) y todas están enlazadas desde una **app "hub" desplegable** (`hub/app.R`) que usa la estética violeta del curso.

## Cómo correr las apps

Necesitás R y RStudio. Instalá los paquetes una sola vez:

```r
install.packages(c("shiny", "bslib", "ggplot2", "DT", "scales",
                   "readr", "dplyr", "rsconnect"))
```

Después, abrí cualquier `clase-XX/app.R` en RStudio y hacé clic en **Run App**. Los ejemplos leen los datos desde la carpeta `datos/`, así que conviene abrir el proyecto desde la raíz del repositorio.

## Estructura del repositorio

```
curso-shiny/
├── README.md                 (este archivo)
├── GUIA-DEPLOY.md            (publicar en shinyapps.io, paso a paso)
├── datos/                    (datos limpios, listos para las apps)
│   └── censo_departamentos.csv
├── datos-crudos/             (scripts que bajan datos oficiales y los preparan)
│   └── preparar_elecciones_2024.R
├── hub/                      (app portada que enlaza las 10 clases)
│   └── app.R
├── clase-01/ ... clase-10/   (una app de ejemplo por clase + README)
└── LICENSE
```

## Programa de las 10 clases

| # | Tema | Qué construimos en la app de ejemplo |
|---|------|--------------------------------------|
| 1 | Bases de RStudio y Shiny | App mínima: `ui`, `server`, una tabla y un texto. |
| 2 | Interfaz de Usuario (UI) | Maqueta con `sidebarLayout()` y pestañas (sin reactividad). |
| 3 | Entradas de Datos (Inputs) | Menús, sliders y cajas de texto; leemos sus valores. |
| 4 | Salidas (Outputs) | `render*` que filtran una tabla según los controles. |
| 5 | El Motor Reactivo | `reactive()`, `req()` y buenas prácticas anti-repetición. |
| 6 | Gráficos Dinámicos | Barras y dispersión con **ggplot2** reactivo. |
| 7 | Estética y Navegación | Tema violeta con **bslib**, `page_navbar`, cards y value boxes. |
| 8 | Puesta en Producción | App integrada (DT, descargas) y deploy a shinyapps.io. |
| 9 | Trabajo Final (I) | Plantilla para tu propia Shiny con tus datos. |
| 10 | Trabajo Final (II) | Módulos de Shiny, cierre, deploy y presentación. |

## Datos

Se privilegian **fuentes oficiales del Estado uruguayo**, apropiadas para Ciencias Sociales.

- **`datos/censo_departamentos.csv`** — Población por departamento, Censos 2011 y 2023, superficie, variación intercensal y densidad. Fuente: **Instituto Nacional de Estadística (INE)**, resultados finales del Censo 2023. Es el dataset que usamos en las clases 1 a 8. Los totales del archivo coinciden con las cifras oficiales (3.286.314 en 2011 y 3.499.451 en 2023).
- **`datos-crudos/preparar_elecciones_2024.R`** — Script reproducible que descarga los microdatos oficiales de la **Corte Electoral** (Elección Nacional 2024) desde el Catálogo de Datos Abiertos del Estado y los agrega por departamento. Es ideal como base para los trabajos finales de temática electoral.

Otras fuentes oficiales recomendadas para los trabajos finales: Corte Electoral, MIDES, INE, y el Catálogo de Datos Abiertos (`catalogodatos.gub.uy`).

## Estética del curso

La identidad visual usa una paleta violeta: violeta profundo `#2E0A4E`, violeta `#5A189A`, violeta claro `#9D4EDD` y acento `#C77DFF`, con tipografía **Oswald** para títulos e **Inter** para el texto. Está aplicada en las clases 7 y 8 y en el hub.

## Publicación

El hub y la app de la Clase 8 se publican en **shinyapps.io**. Ver `GUIA-DEPLOY.md` para el paso a paso.

## Bibliografía

- Wickham, H. (2021). *Mastering Shiny*. O'Reilly Media.
- Sievert, C. (2020). *Interactive web-based data visualization with R, plotly, and shiny*. Chapman and Hall/CRC.
- Beeley, C. (2018). *Hands-On Dashboard Development with Shiny*. Packt Publishing.
