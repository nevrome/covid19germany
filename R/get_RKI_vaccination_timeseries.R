#' get_RKI_vaccination_timeseries
#'
#' Downloads the latest version of a COVID-19 vaccination time series dataset by the 
#' Robert Koch Institute.
#' Please see the README for more information: \url{https://github.com/nevrome/covid19germany}
#'
#' @param url character. Data source url
#' @param raw_only logical. Should covid19germany data cleaning not be applied
#'
#' @return A tibble with the dataset
#'
#' @examples 
#' \donttest{
#' rki_vaccination_progress <- get_RKI_vaccination_timeseries()
#' }
#' 
#' @export 
get_RKI_vaccination_timeseries <- function(
  url = paste0(
    "https://www.rki.de/",
    "DE/Content/InfAZ/N/Neuartiges_Coronavirus/Daten/Impfquotenmonitoring.xlsx",
    "?__blob=publicationFile"
  ),
  raw_only = FALSE
) {
  
  message("Downloading file...")
  excel_table <- tempfile()
  utils::download.file(url, excel_table)
  
  message("Loading file into R...")
  
  vaccination_ts <- readxl::read_xlsx(
    excel_table, sheet = 4, n_max = as.numeric(
      lubridate::today() - lubridate::date("2020-12-27")
    )
  ) %>%
    dplyr::mutate(
      Datum = lubridate::as_date(.data[["Datum"]], format = "%d.%m.%Y")
    )
  
  file.remove(excel_table)
  
  if (raw_only) {
    return(vaccination_ts)
  }
  
  message("Processing...")
  res <- vaccination_ts %>%
    dplyr::rename(
      Date = "Datum",
      NumberVaccinatedOnce = "Erstimpfung",
      NumberFullyVaccinated = "Zweitimpfung",
      NumberVaccinations = "Gesamtzahl verabreichter Impfstoffdosen"
    ) %>%
    dplyr::mutate(
      dplyr::across(where(is.numeric), as.integer)
    ) %>%
    dplyr::mutate(
      NumberFullyVaccinated = tidyr::replace_na(.data[["NumberFullyVaccinated"]], 0)
    )
  
  return(res)
}
