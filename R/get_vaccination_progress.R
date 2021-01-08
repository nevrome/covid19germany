#' get_RKI_vaccination_progress
#'
#' Downloads the latest version of a COVID-19 vaccination progress dataset by the 
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
#' rki_vaccination_progress <- get_RKI_vaccination_progress()
#' }
#' 
#' @export 
get_RKI_vaccination_progress <- function(
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
  
  # vaccination_meta <- readxl::read_xlsx(
  #   excel_table, 
  #   sheet = 1,
  #   col_names = FALSE,
  #   col_types = c("text")
  # )
  
  # code is correct, but RKI table is wrong (4.1.2021)
  # time_of_last_update <- vaccination_meta[6,1] %>%
  #   as.character() %>%
  #   gsub("Datenstand: ", "", .) %>%
  #   lubridate::as_datetime(
  #     format = "%d.%m.%Y, %H:%M Uhr", 
  #     tz = "Europe/Berlin"
  #   )

  vaccination_data <- readxl::read_xlsx(
    excel_table, sheet = 2, n_max = 16
  )

  file.remove(excel_table)
  
  if (raw_only) {
    return(vaccination_data)
  }
  
  message("Processing...")
  res <- vaccination_data %>%
    dplyr::rename(
      CumNumberVaccinated = "Impfungen kumulativ",
      NewNumberVaccinated = "Differenz zum Vortag",
      NumberVaccinatedPer1000 = "Impfungen pro 1.000 Einwohner",
      IndicationAge = "Indikation nach Alter*",
      IndicationProfession = "Berufliche Indikation*",
      IndicationMedical = "Medizinische Indikation*",
      IndicationCareHome = "Pflegeheim-bewohnerIn*",
      Comment = .data[[colnames(.)[ncol(.)]]]
    ) %>%
    dplyr::mutate(
      dplyr::across(where(is.numeric), as.integer)
    ) %>%
    tibble::add_column(DownloadDate = lubridate::today(), .before = 1)
  
  return(res)
}
