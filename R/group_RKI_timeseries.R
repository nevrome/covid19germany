#' group_RKI_timeseries
#'
#' Restructures the RKI data to a grouped time series data.frame. Days with no observations are added to make them 
#' explicit. Grouping can be done with one or multiple variables (see parameter \code{...}).
#' Please see the README for more information: \url{https://github.com/nevrome/covid19germany}
#' 
#' @param x data.frame. RKI data as downloaded with \code{\link{get_RKI_timeseries}}
#' @param ... variable names. One or multiple grouping columns of x, so Bundesland, Landkreis, Geschlecht or Altersgruppe
#'
#' @examples 
#' rki_timeseries <- get_RKI_timeseries()
#' 
#' group_RKI_timeseries(rki_timeseries, Bundesland, Geschlecht)
#'
#' @export
group_RKI_timeseries <- function(x, ...) {
  
  .grouping_var <- rlang::ensyms(...)
  
  res <- x %>% 
    dplyr::select(
      !!!.grouping_var, "AnzahlFall", "AnzahlTodesfall", "Meldedatum"
    ) %>% 
    dplyr::group_by(
      !!!.grouping_var, .data[["Meldedatum"]]
    ) %>%
    dplyr::summarise(
      AnzahlFall = sum(.data[["AnzahlFall"]]),
      AnzahlTodesfall = sum(.data[["AnzahlTodesfall"]])
    ) %>%
    dplyr::ungroup() %>%
    tidyr::complete(
      tidyr::nesting(!!!.grouping_var),
      Meldedatum = tidyr::full_seq(.data[["Meldedatum"]], 24*60*60),
      fill = list(AnzahlFall = 0, AnzahlTodesfall = 0)
    ) %>% dplyr::group_by(
      !!!.grouping_var
    ) %>%
    dplyr::mutate(
      KumAnzahlFall = cumsum(.data[["AnzahlFall"]]),
      KumAnzahlTodesfall = cumsum(.data[["AnzahlTodesfall"]])
    ) %>%
    dplyr::ungroup()
  
  if ("Bundesland" %in% colnames(res)) {
    res <- res %>%
      dplyr::left_join(
        x %>% dplyr::select("IdBundesland", "Bundesland") %>% unique, by = "Bundesland"
      )
  }
  
  if ("Landkreis" %in% colnames(res)) {
    res <- res %>%
      dplyr::left_join(
        x %>% dplyr::select("IdLandkreis", "Landkreis") %>% unique, by = "Landkreis"
      )
  }
  
  return(res)
  
}
