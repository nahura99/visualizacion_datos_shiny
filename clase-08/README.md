# Clase 8 · Estética y Navegación

## Objetivo
Entender el bloque de estética que venimos copiando desde la Clase 2, organizar la navegación con bslib y jerarquizar la información con cards y value boxes. Tablas interactivas con DT.

## Qué hace la app
Un tablero con barra de navegación y tres pestañas (Resumen, Gráficos, Tabla). La barra lateral muestra controles distintos según la pestaña activa. Value boxes, cards, acordeón, modo oscuro y una tabla DT con búsqueda, filtros por columna y exportación.

## Componentes que se explican en clase
| Componente | Para qué sirve |
|---|---|
| `bs_theme()` | Un tema de Bootstrap 5. Colores, fuentes y cualquier variable entre comillas (`"navbar-bg"`). |
| `font_google()` | Fuentes de Google (Inter y Oswald en el curso). |
| `bs_themer()` | Panel para probar colores en vivo mientras desarrollás. |
| `page_navbar()`, `nav_panel()`, `nav_spacer()`, `nav_item()` | Navegación por pestañas arriba. Con `id`, el server sabe cuál está activa. |
| `sidebar()` | Barra lateral plegable. |
| `layout_columns()` | Reparte el ancho entre sus hijos. `col_widths` fija las proporciones. |
| `card()`, `card_header()`, `card_footer()` | Tarjetas con título y pie. |
| `value_box()` y `value_box_theme()` | Indicadores grandes con ícono. |
| `accordion()` y `accordion_panel()` | Secciones plegables. |
| `conditionalPanel()` | Mostrar controles solo cuando se cumple una condición (en JavaScript). |
| `input_dark_mode()` y `tooltip()` | Modo oscuro y ayudas contextuales. |
| `tags$style()` | CSS propio para lo que el tema no cubre. |
| `DTOutput()`, `renderDT()`, `datatable()` | Tabla interactiva. `filter`, `extensions = "Buttons"`, `formatStyle()`. |

## Cómo correr la app
Abrí `app.R` en RStudio y hacé clic en **Run App**. Necesitás `bslib` (0.6 o más nuevo) y `DT`.

## Ejercicio propuesto
Cambiá la paleta a los colores de tu facultad o institución, agregá un cuarto `nav_panel()` "Acerca de" y un `value_box()` con el departamento más reñido.

---
Curso *Visualización interactiva de datos con R y Shiny* · Udelar.
