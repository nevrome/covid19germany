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
    col_types = readr::cols(
      IdBundesland = readr::col_double(),
      Bundesland = readr::col_character(),
      Landkreis = readr::col_character(),
      Altersgruppe = readr::col_character(),
      Geschlecht = readr::col_character(),
      AnzahlFall = readr::col_double(),
      AnzahlTodesfall = readr::col_double(),
      ObjectId = readr::col_double(),
      Meldedatum = readr::col_datetime(format = ""),
      IdLandkreis = readr::col_character()
    )
  )
  
}
