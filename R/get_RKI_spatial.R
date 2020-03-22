#' get_RKI_spatial
#'
#' Downloads the latest version of a COVID-19 spatial dataset by the Robert Koch Institute.
#' Please see the README for more information: \url{https://github.com/nevrome/covid19germany}
#'
#' @param resolution character. Resolution of the spatial data: "Bundesland" or "Landkreis"
#' @param urls named character vector. Data source urls
#' @param cache logical. Should the data be cached?
#' @param cache_dir character. Path to cache directory
#' @param cache_max_age numeric. Maximum age of cache in seconds
#'
#' @return An object of class sf with the dataset
#'
#' @examples 
#' rki_spatial_Bundesland <- get_RKI_spatial()
#' 
#' @export 
get_RKI_spatial <- function(
  resolution = "Bundesland", 
  urls = c(
    "Bundesland" = "https://opendata.arcgis.com/datasets/ef4b445a53c1406892257fe63129a8ea_0.zip",
    "Landkreis" = "https://opendata.arcgis.com/datasets/917fc37a709542548cc3be077a786c17_0.zip"
  ),
  cache = T, cache_dir = tempdir(), cache_max_age = 24 * 60 * 60
) {
  
  check_if_packages_are_available("sf")
  
  url <- urls[names(urls) == resolution]

  # caching is activated
  if (cache) {
    if (!dir.exists(cache_dir)) { dir.create(cache_dir) }
    tab_cache_file <- file.path(cache_dir, paste0("RKI_spatial_", resolution, ".RData"))
    if (file.exists(tab_cache_file) & file.mtime(tab_cache_file) > (Sys.time() - cache_max_age)) {
      load(tab_cache_file)
    } else {
      this_tab <- download_RKI_spatial(url, resolution)
      save(this_tab, file = tab_cache_file)
    }
    # caching is not activated
  } else {
    this_tab <- download_RKI_spatial(url, resolution)
  }
  
  return(this_tab)
  
}

download_RKI_spatial <- function(url, resolution) {
  
  shape_zip <- tempfile()
  unzip_dir <- file.path(tempdir(), "RKI_spatial_shapefiles")
  utils::download.file(url, destfile = shape_zip)
  utils::unzip(shape_zip, exdir = unzip_dir)
  
  if (resolution == "Bundesland") {
    sf_object <- sf::read_sf(file.path(unzip_dir, "RKI_Corona_Bundesl\u00E4nder.shp")) %>% 
      dplyr::mutate(
        Bundesland = .data[["LAN_ew_GEN"]]  
      )
  } else if (resolution == "Landkreis") {
    sf_object <- sf::read_sf(file.path(unzip_dir, "RKI_Corona_Landkreise.shp")) %>% 
      dplyr::mutate(
        IdLandkreis = as.integer(.data[["RS"]])  
      )
  }

  return(sf_object)
}