#' get_RKI_timeseries
#'
#' Downloads the latest version of a COVID-19 timeseries dataset by the Robert Koch Institute.
#' Please see the README for more information: \url{https://github.com/nevrome/covid19germany}
#'
#' @param url character. Data source url
#' @param cache logical. Should the data be cached?
#' @param cache_dir character. Path to cache directory
#' @param cache_max_age numeric. Maximum age of cache in seconds
#'
#' @return A tibble with the dataset
#'
#' @examples
#' \donttest{ 
#' rki_timeseries <- get_RKI_timeseries()
#' }
#' 
#' @export 
get_RKI_timeseries <- function(
  url = "https://opendata.arcgis.com/datasets/dd4580c810204019a7b8eb3e0b329dd6_0.csv", 
  cache = T, cache_dir = tempdir(), cache_max_age = 24 * 60 * 60
) {
  
  # caching is activated
  if (cache) {
    if (!dir.exists(cache_dir)) { dir.create(cache_dir) }
    tab_cache_file <- file.path(cache_dir, paste0("RKI_timeseries.RData"))
    if (file.exists(tab_cache_file) & file.mtime(tab_cache_file) > (Sys.time() - cache_max_age)) {
      load(tab_cache_file)
    } else {
      this_tab <- download_RKI(url)
      save(this_tab, file = tab_cache_file)
    }
  # caching is not activated
  } else {
    this_tab <- download_RKI(url)
  }
  
  return(this_tab) 
}

download_RKI <- function(url) {
  
  readr::read_csv(
    url,
    na = c("0-1", "-1", "unbekannt", "-nicht erhoben-"),
    col_types = readr::cols(
      IdBundesland = readr::col_integer(),
      Bundesland = readr::col_character(),
      Landkreis = readr::col_character(),
      Altersgruppe = readr::col_factor(
        levels = c("A00-A04", "A05-A14", "A15-A34", "A35-A59", "A60-A79", "A80+"), 
        ordered = T,
        include_na = T
      ),
      Geschlecht = readr::col_factor(
        include_na = T
      ),
      AnzahlFall = readr::col_integer(),
      AnzahlTodesfall = readr::col_integer(),
      ObjectId = readr::col_integer(),
      Meldedatum = readr::col_datetime(format = ""),
      IdLandkreis = readr::col_integer()
    )
  ) %>%
    dplyr::transmute(
      ObjectId = .data[["ObjectId"]],
      Date = .data[["Meldedatum"]],
      IdBundesland = .data[["IdBundesland"]],
      Bundesland = .data[["Bundesland"]],
      IdLandkreis = .data[["IdLandkreis"]],
      Landkreis = .data[["Landkreis"]],
      Age = .data[["Altersgruppe"]],
      Gender = .data[["Geschlecht"]],
      NumberNewTestedIll = .data[["AnzahlFall"]],
      NumberNewDead = .data[["AnzahlTodesfall"]],
    )
  
}
