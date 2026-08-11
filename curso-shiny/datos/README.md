# Datos

## `censo_departamentos.csv`

Población por departamento de Uruguay según los Censos de 2011 y 2023.

| Columna | Descripción |
|---------|-------------|
| `departamento` | Nombre del departamento (19 en total). |
| `region` | Agrupación regional usada en el curso (Metropolitana, Litoral, Norte, Centro, Este). |
| `poblacion_2011` | Población en el Censo 2011. |
| `poblacion_2023` | Población en el Censo 2023. |
| `superficie_km2` | Superficie del departamento en km². |
| `variacion_pct` | Variación porcentual de población 2011 → 2023. |
| `densidad_2023` | Habitantes por km² en 2023. |

**Fuente:** Instituto Nacional de Estadística (INE), resultados finales del Censo 2023, y Censo 2011. Los totales del archivo coinciden con las cifras oficiales: 3.286.314 habitantes (2011) y 3.499.451 (2023). La regionalización es una simplificación pedagógica.

## Datos electorales (Corte Electoral)

No se incluyen precargados por su tamaño (nivel de circuito). Se generan con el script `../datos-crudos/preparar_elecciones_2024.R`, que los descarga directamente del Catálogo de Datos Abiertos del Estado y los agrega por departamento. Fuente original: Corte Electoral, Elección Nacional 2024.
