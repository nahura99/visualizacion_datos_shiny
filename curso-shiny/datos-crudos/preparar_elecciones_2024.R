# =============================================================================
# preparar_elecciones_2024.R
# -----------------------------------------------------------------------------
# Descarga y agrega los datos oficiales de la ELECCIÓN NACIONAL 2024
# publicados por la CORTE ELECTORAL en el Catálogo de Datos Abiertos del Estado.
#
# Fuente (original, oficial):
#   Corte Electoral - Elecciones Nacionales 2024
#   https://catalogodatos.gub.uy/dataset/corte-electoral-elecciones-nacionales-2024
#   Licencia de Datos Abiertos de Uruguay (AGESIC).
#
# Este script NO usa fuentes secundarias (prensa, Wikipedia): baja los CSV
# directamente del servidor de datos abiertos y los agrega por departamento.
#
# Salida:
#   ../datos/participacion_2024_departamento.csv
#
# Cómo correrlo (desde RStudio o R):
#   setwd("datos-crudos"); source("preparar_elecciones_2024.R")
# =============================================================================

# Paquetes -------------------------------------------------------------------
# install.packages(c("readr", "dplyr"))  # si no los tenés instalados
library(readr)
library(dplyr)

# URL oficial del recurso CSV "Totales generales por Comisión Receptora de
# Votos y Plebiscitos Constitucionales" (nivel circuito/mesa).
url_totales <- paste0(
  "https://catalogodatos.gub.uy/dataset/",
  "7aaa1ff0-8ea5-4302-a3e6-c2d589b484a3/resource/",
  "0f149bb6-4fff-463b-bc3a-8ab671bcdf34/download/",
  "totales-generales-por-comision-receptora-de-votos-y-",
  "plebiscitos-constitucionales.csv"
)

# Descarga y lectura ---------------------------------------------------------
destino <- "totales_generales_crv_2024.csv"
if (!file.exists(destino)) {
  message("Descargando datos oficiales de la Corte Electoral...")
  download.file(url_totales, destino, mode = "wb")
}

crv <- readr::read_csv(destino, show_col_types = FALSE)

# Diccionario de códigos de departamento (Corte Electoral) -------------------
deptos <- c(
  AR = "Artigas",   CA = "Canelones", CL = "Cerro Largo", CO = "Colonia",
  DU = "Durazno",   FS = "Flores",    FD = "Florida",     LA = "Lavalleja",
  MA = "Maldonado", MO = "Montevideo",PA = "Paysandú",    RN = "Río Negro",
  RV = "Rivera",    RO = "Rocha",     SA = "Salto",       SJ = "San José",
  SO = "Soriano",   TA = "Tacuarembó",TT = "Treinta y Tres"
)

# Agregación por departamento ------------------------------------------------
participacion <- crv |>
  group_by(Departamento) |>
  summarise(
    habilitados = sum(TotalHabilitados, na.rm = TRUE),
    emitidos    = sum(TotalVotosEmitidos, na.rm = TRUE),
    en_blanco   = sum(TotalEnBlanco, na.rm = TRUE),
    anulados    = sum(TotalAnulados, na.rm = TRUE),
    .groups = "drop"
  ) |>
  mutate(
    departamento     = dplyr::recode(Departamento, !!!deptos),
    participacion_pct = round(emitidos / habilitados * 100, 1),
    blancos_pct      = round(en_blanco / emitidos * 100, 1),
    anulados_pct     = round(anulados / emitidos * 100, 1)
  ) |>
  select(departamento, habilitados, emitidos,
         participacion_pct, en_blanco, blancos_pct, anulados, anulados_pct) |>
  arrange(desc(emitidos))

# Guardado -------------------------------------------------------------------
if (!dir.exists("../datos")) dir.create("../datos")
readr::write_csv(participacion, "../datos/participacion_2024_departamento.csv")

message("Listo. Archivo generado en datos/participacion_2024_departamento.csv")
print(participacion)

# -----------------------------------------------------------------------------
# NOTA (avanzado): para obtener VOTOS POR PARTIDO (lema) por departamento,
# se combinan otros dos recursos del mismo dataset:
#   - "Desglose de votos"  (votos por hoja de votación en cada circuito)
#   - "Integración de hojas de votación"  (mapea cada hoja -> partido/lema)
# El procedimiento es: leer desglose, unir con la tabla de hojas por el número
# de hoja, y agregar por (departamento, partido). Se deja como ejercicio /
# material de las clases avanzadas y de los trabajos finales.
# -----------------------------------------------------------------------------
