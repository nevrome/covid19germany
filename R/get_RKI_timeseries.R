#' get_RKI_timeseries
#'
#' Downloads the latest version of a COVID-19 timeseries dataset by the Robert Koch Institute.
#' Please see the README for more information: \url{https://github.com/nevrome/covid19germany}
#'
#' @param url character. Data source url
#' @param cache logical. Should the data be cached?
#' @param cache_dir character. Path to cache directory
#' @param cache_max_age numeric. Maximum age of cache in seconds or "today"
#' @param raw_only logical. Do not apply covid19germany filters to RKI data (raw_only = T) or do filter them (default, raw_only = F)
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
  url = paste0(
    "https://www.arcgis.com",
    "/sharing/rest/content/items/f10774f1c63e40168479a1feb6c7ca74/data"
  ),
  cache = T, cache_dir = tempdir(), cache_max_age = "today", raw_only = F
) {

  if (cache_max_age == "today") {
    cache_threshold <- lubridate::now() - lubridate::as.duration(
      lubridate::interval(lubridate::today(), lubridate::now())
    )
  } else {
    cache_threshold <- lubridate::now() - lubridate::as.duration(
      cache_max_age
    )
  }

  # caching is activated
  # (too cumbersome to check contents of chached dataset if raw_only is active)
  if (cache && !raw_only) {
    if (!dir.exists(cache_dir)) { dir.create(cache_dir) }
    tab_cache_file <- file.path(cache_dir, paste0("RKI_timeseries.RData"))
    if (file.exists(tab_cache_file) & file.mtime(tab_cache_file) > cache_threshold) {
      message("Loading file from cache...")
      load(tab_cache_file)
    } else {
      this_tab <- download_RKI(url)
      save(this_tab, file = tab_cache_file)
    }
  # caching is not activated
  } else {
    this_tab <- download_RKI(url, raw_only)
  }

  return(this_tab)
}

download_RKI <- function(url, raw_only = F) {

  message("Downloading file...")
  naked_download_file <- tempfile(fileext = ".csv")
  utils::download.file(url, naked_download_file)
  
  message("Loading file into R...")
  download <- readr::read_csv(
    naked_download_file,
    na = c("0-1", "unbekannt", "-nicht erhoben-", "Nicht \u00FCbermittelt"),
    col_types = readr::cols(
      # depending on if the original URL or the alternative one is used either 
      # ObjectId or FID exists - to avoid a warning we let readr figure out the type
      # automatically
      #FID = readr::col_integer(),
      #ObjectId = readr::col_integer(),
      IdBundesland = readr::col_integer(),
      Bundesland = readr::col_character(),
      Landkreis = readr::col_character(),
      Altersgruppe = readr::col_factor(
        levels = c("A00-A04", "A05-A14", "A15-A34", "A35-A59", "A60-A79", "A80+"),
        ordered = T,
        include_na = T
      ),
      Altersgruppe2 = readr::col_character(),
      Geschlecht = readr::col_factor(
        include_na = T
      ),
      AnzahlFall = readr::col_integer(),
      AnzahlTodesfall = readr::col_integer(),
      AnzahlGenesen = readr::col_integer(),
      Meldedatum = readr::col_datetime(format = "%Y/%m/%d %H:%M:%S"),
      IdLandkreis = readr::col_integer(),
      Datenstand = readr::col_datetime(format = "%d.%m.%Y, %H:%M Uhr"),
      NeuerFall = readr::col_integer(),
      NeuerTodesfall = readr::col_integer(),
      NeuGenesen = readr::col_integer(),
      Refdatum = readr::col_datetime(format = "%Y/%m/%d %H:%M:%S"),
      IstErkrankungsbeginn = readr::col_integer()
    )
  )

  file.remove(naked_download_file)
  
  if ( raw_only ){
    return(download)
  }
  
  message("Processing file...")
  # name change for alternative URL
  if ("FID" %in% colnames(download)) {
    download <- download %>% dplyr::rename(ObjectId = .data[["FID"]])
  }
  
  download <- download %>% 
    dplyr::mutate(
      StartOfDiseaseDate = lubridate::as_datetime(ifelse(
        .data[["IstErkrankungsbeginn"]] == 1, 
        .data[["Refdatum"]], 
        NA
      ))
    )

  # get correct count of testedill, dead and recovered
  testedill <- download %>%
    dplyr::filter(
      .data[["NeuerFall"]] %in% c(0, 1)
    ) %>%
    dplyr::transmute(
      Version = .data[["Datenstand"]],
      ObjectId = .data[["ObjectId"]],
      Date = .data[["Meldedatum"]],
      IdBundesland = .data[["IdBundesland"]],
      Bundesland = .data[["Bundesland"]],
      IdLandkreis = .data[["IdLandkreis"]],
      Landkreis = .data[["Landkreis"]],
      Age = .data[["Altersgruppe"]],
      Gender = .data[["Geschlecht"]],
      StartOfDiseaseDate = .data[["StartOfDiseaseDate"]],
      NumberNewTestedIll = .data[["AnzahlFall"]]
    ) 
  
  dead <- download %>%
    dplyr::filter(
      .data[["NeuerTodesfall"]] %in% c(0, 1)
    ) %>%
    dplyr::transmute(
      Version = .data[["Datenstand"]],
      ObjectId = .data[["ObjectId"]],
      Date = .data[["Meldedatum"]],
      IdBundesland = .data[["IdBundesland"]],
      Bundesland = .data[["Bundesland"]],
      IdLandkreis = .data[["IdLandkreis"]],
      Landkreis = .data[["Landkreis"]],
      Age = .data[["Altersgruppe"]],
      Gender = .data[["Geschlecht"]],
      StartOfDiseaseDate = .data[["StartOfDiseaseDate"]],
      NumberNewDead = .data[["AnzahlTodesfall"]]
    ) 
  
  recovered <- download %>%
    dplyr::filter(
      .data[["NeuGenesen"]] %in% c(0, 1)
    ) %>%
    dplyr::transmute(
      Version = .data[["Datenstand"]],
      ObjectId = .data[["ObjectId"]],
      Date = .data[["Meldedatum"]],
      IdBundesland = .data[["IdBundesland"]],
      Bundesland = .data[["Bundesland"]],
      IdLandkreis = .data[["IdLandkreis"]],
      Landkreis = .data[["Landkreis"]],
      Age = .data[["Altersgruppe"]],
      Gender = .data[["Geschlecht"]],
      StartOfDiseaseDate = .data[["StartOfDiseaseDate"]],
      NumberNewRecovered = .data[["AnzahlGenesen"]]
    ) 
  
  merged <- testedill %>% dplyr::full_join(
    dead, 
    by = c(
      "Version", 
      "ObjectId", 
      "Date", 
      "IdBundesland", 
      "Bundesland", 
      "IdLandkreis", 
      "Landkreis", 
      "Age", 
      "Gender",
      "StartOfDiseaseDate"
    )
  ) %>%
    dplyr::full_join(
      recovered, 
      by = c(      
        "Version", 
        "ObjectId", 
        "Date", 
        "IdBundesland", 
        "Bundesland", 
        "IdLandkreis", 
        "Landkreis", 
        "Age", 
        "Gender",
        "StartOfDiseaseDate"
      )
    )
  
  res <- merged %>%
    # merge double observations
    dplyr::group_by(
      .data[["Version"]],
      .data[["Date"]],
      .data[["StartOfDiseaseDate"]],
      .data[["IdBundesland"]],
      .data[["Bundesland"]],
      .data[["IdLandkreis"]],
      .data[["Landkreis"]],
      .data[["Age"]],
      .data[["Gender"]]
    ) %>%
    dplyr::summarise(
      NumberNewTestedIll = sum(.data[["NumberNewTestedIll"]], na.rm = T),
      NumberNewDead = sum(.data[["NumberNewDead"]], na.rm = T),
      NumberNewRecovered = sum(.data[["NumberNewRecovered"]], na.rm = T)
    ) %>%
    dplyr::ungroup()

  return(res)

}
