#' get_RKI_timeseries
#'
#' @param cache logical. Should data be cached?
#' @param cache_dir character. Path to cache directory
#' @param cache_max_age numeric. Maximum age of cache in seconds
#'
#' @export
get_RKI_timeseries <- function(cache = T, cache_dir = tempdir(), cache_max_age = 24 * 60 * 60) {
  
  # caching is activated
  if (cache) {
    if (!dir.exists(cache_dir)) { dir.create(cache_dir) }
    tab_cache_file <- file.path(cache_dir, paste0("RKI_timeseries.RData"))
    if (file.exists(tab_cache_file) & file.mtime(tab_cache_file) > (Sys.time() - cache_max_age)) {
      load(tab_cache_file)
    } else {
      this_tab <- download_RKI()
      save(this_tab, file = tab_cache_file)
    }
  # caching is not activated
  } else {
    this_tab <- download_RKI()
  }
  
  return(this_tab) 
}

download_RKI <- function() {
  
  readr::read_csv(
    "https://opendata.arcgis.com/datasets/dd4580c810204019a7b8eb3e0b329dd6_0.csv",
    na = c("0-1", "-1", "unbekannt", "-nicht erhoben-"),
    col_types = readr::cols(
      IdBundesland = readr::col_integer(),
      Bundesland = readr::col_character(),
      Landkreis = readr::col_character(),
      Altersgruppe = readr::col_factor(
        levels = c("A00-A04", "A05-A14", "A15-A34", "A35-A59", "A60-A79", "A80+"), 
        ordered = T
      ),
      Geschlecht = readr::col_factor(),
      AnzahlFall = readr::col_integer(),
      AnzahlTodesfall = readr::col_integer(),
      ObjectId = readr::col_double(),
      Meldedatum = readr::col_datetime(format = ""),
      IdLandkreis = readr::col_integer()
    )
  )
  
}
