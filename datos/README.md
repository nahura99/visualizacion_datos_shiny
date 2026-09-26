# Datos

La app principal del curso (clases 2 a 9) se construye sobre los resultados de la **Elección Nacional 2024** de Uruguay.

## `elecciones_departamento_2024.csv`

Resultados agregados por departamento (19 filas). Es el dataset que usan las clases 2 a 8 y los paneles de gráficos y tablas de la Clase 9.

| Columna | Descripción |
|---------|-------------|
| `departamento` | Nombre del departamento (19 en total). |
| `region` | Agrupación regional usada en el curso (Metropolitana, Litoral, Norte, Centro, Este). |
| `habilitados` | Personas habilitadas para votar. |
| `emitidos` | Votos emitidos. |
| `participacion_pct` | Participación (%), votos no observados sobre habilitados. |
| `en_blanco_pct` / `anulados_pct` | Voto en blanco y anulado, como % de los emitidos. |
| `lema_ganador` | Lema más votado en el departamento. |
| `pct_ganador` | % del lema ganador sobre los votos válidos a lemas. |
| `margen_pct` | Diferencia en puntos porcentuales entre el primero y el segundo. |
| `votos_frente_amplio`, `votos_partido_nacional`, `votos_partido_colorado`, `votos_cabildo_abierto` | Votos de los cuatro lemas más votados a nivel país. |
| `pct_frente_amplio`, `pct_partido_nacional`, `pct_partido_colorado`, `pct_cabildo_abierto` | Su porcentaje sobre los votos válidos a lemas. |
| `pct_si_art11` / `pct_si_art67` | % de SÍ a los plebiscitos (allanamientos nocturnos / seguridad social), sobre votos no observados. |

**Fuente:** Corte Electoral, totales generales por circuito (CRV) y plebiscitos constitucionales, agregados por departamento. Los totales nacionales reproducen exactamente el escrutinio definitivo (Frente Amplio 1.071.826, Partido Nacional 655.426, Partido Colorado 392.592, habilitados 2.727.120, emitidos 2.443.801).

## `elecciones_locales_2024.csv` y `elecciones_circuitos_2024.csv`

Los mismos resultados, pero georreferenciados y sin agregar por departamento. Es lo que consumen el histograma de la Clase 7 y los paneles de tablas y mapas de la Clase 9.

- **`elecciones_locales_2024.csv`** — 2.521 filas, una por local de votación (suma los circuitos que funcionan en el mismo edificio). Es la unidad recomendada para el mapa.
- **`elecciones_circuitos_2024.csv`** — 7.352 filas, una por Departamento + CRV. Es la unidad oficial del escrutinio, con el máximo detalle.

Cada fila trae: identificación y coordenadas (con su precisión), totales del escrutinio, votos y % de cada uno de los 11 lemas, lema ganador y margen, participación, voto en blanco/anulado/observado, y % de SÍ a cada plebiscito.

**Precisión de las coordenadas:** de los 2.521 locales, 2.475 están georreferenciados (1.567 con precisión alta, 307 media, 601 baja —típicamente escuelas rurales identificadas por ruta y kilómetro—). Los circuitos con numeración 9.000 o mayor son "fictos" (escrutan votos observados, sin local físico) y no aparecen en el mapa, aunque sí en los totales.

**Fuente:** Corte Electoral (plan circuital 2024, totales generales por CRV y plebiscitos, desglose de votos por hoja de votación), cruzado con el geocodificador oficial de **IDE Uruguay** (`direcciones.ide.uy`).

## `censo_departamentos.csv`

Población por departamento de Uruguay según los Censos de 2011 y 2023. Ya **no** es la base de la app principal del curso (esa pasó a los datos electorales de arriba), pero queda en el repositorio como dataset alternativo, simple, para practicar o para quien prefiera arrancar su trabajo final desde ahí.

| Columna | Descripción |
|---------|-------------|
| `departamento` | Nombre del departamento (19 en total). |
| `region` | Agrupación regional usada en el curso. |
| `poblacion_2011` | Población en el Censo 2011. |
| `poblacion_2023` | Población en el Censo 2023. |
| `superficie_km2` | Superficie del departamento en km². |
| `variacion_pct` | Variación porcentual de población 2011 → 2023. |
| `densidad_2023` | Habitantes por km² en 2023. |

**Fuente:** Instituto Nacional de Estadística (INE), resultados finales del Censo 2023, y Censo 2011.
