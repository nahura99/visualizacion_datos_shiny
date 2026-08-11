# Clase 10 — Trabajo Final (II): terminar, escalar y presentar

## Objetivo
Dar el toque final a tu Shiny, aprender a escalar apps complejas con **módulos** y presentar el trabajo.

## La app de referencia
`app.R` muestra el patrón de **módulos de Shiny** (`NS()`, `moduleServer()`): un mismo componente reutilizado en tres pestañas. Es la forma de evitar repetir código cuando tu app crece.

## Checklist de cierre
- [ ] La app corre sin errores desde cero.
- [ ] Los filtros funcionan y no rompen con selecciones vacías (`req`/`validate`).
- [ ] Tiene la estética aplicada (tema, títulos, colores).
- [ ] Los datos viajan dentro de la carpeta de la app.
- [ ] Está publicada en shinyapps.io y la URL funciona.
- [ ] El README explica el tema, la pregunta y la fuente de datos.

## Rúbrica de evaluación (orientativa)
| Criterio | Peso | Qué se evalúa |
|----------|------|---------------|
| Funcionamiento | 25% | La app corre y responde a la interacción sin errores. |
| Uso de reactividad | 20% | `reactive()`/`req()` bien usados; código sin repetición innecesaria. |
| Visualización | 20% | Gráficos claros y pertinentes a la pregunta. |
| Diseño e interfaz | 15% | Navegación ordenada, estética y textos que guían. |
| Datos y fuente | 10% | Datos oficiales o justificados, correctamente citados. |
| Publicación | 10% | App desplegada y accesible por URL. |

## Presentación (5–8 minutos)
1. El tema y la pregunta.
2. La fuente de datos.
3. Demo en vivo de la app.
4. Una decisión de diseño que tomaste y por qué.

---
Curso *Visualización interactiva de datos con R y Shiny* · Udelar.
