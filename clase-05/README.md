# Clase 05 — El Motor Reactivo

## Objetivo
Entender cómo Shiny escucha los inputs y recalcula solo lo necesario.

## Conceptos que se ven
- `reactive()`: calcular una vez y reutilizar en varios outputs.
- `req()`: frenar el cálculo (sin error) cuando falta un input.
- Comparar con la Clase 4 para ver por qué la reactividad ordena el código.

## Cómo correr la app
Abrí `app.R` en RStudio y hacé clic en **Run App** (o ejecutá `shiny::runApp()` desde esta carpeta).

## Ejercicio propuesto
Agregá un segundo `reactive()` que devuelva solo el departamento más poblado del filtro.

---
Curso *Visualización interactiva de datos con R y Shiny* · Udelar.
