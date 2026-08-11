# Clase 09 — Trabajo Final (I): elegí tu tema y arrancá tu Shiny

## Objetivo
Comenzar el trabajo final: una aplicación Shiny sobre un tema de tu interés, con datos de fuentes oficiales o de tu propia investigación.

## La plantilla
`app.R` es una plantilla lista para completar. Buscá los comentarios `# TODO` y reemplazalos por tus datos y tus gráficos. Mientras no cargues tus datos, la plantilla corre igual usando el Censo como ejemplo.

## Cómo empezar
1. Elegí un tema y una **pregunta** que tu app ayude a responder.
2. Conseguí un dataset (idealmente oficial) y guardalo en `datos/mis_datos.csv`.
3. Ajustá en la plantilla: el título, los filtros y el gráfico.

## Ideas de datos (fuentes oficiales uruguayas)
- **Corte Electoral** — resultados electorales (ver `../datos-crudos/preparar_elecciones_2024.R`).
- **MIDES** — indicadores sociales y programas.
- **INE** — censos, encuesta continua de hogares, precios.
- **Catálogo de Datos Abiertos** — `catalogodatos.gub.uy`.

## Checklist para elegir tu dataset
- [ ] Tiene al menos una variable **categórica** (para filtrar) y una **numérica** (para graficar).
- [ ] Está limpio o lo podés limpiar (una fila por observación).
- [ ] Conocés y podés citar la **fuente**.
- [ ] Te permite responder tu pregunta.

---
Curso *Visualización interactiva de datos con R y Shiny* · Udelar.
