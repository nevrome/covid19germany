#' group_RKI_timeseries
#'
#' @param x data.frame. RKI data as downloaded with \code{\link{get_RKI_timeseries}}
#' @param ... character. "Bundesland", "Landkreis", "Geschlecht", "Altersgruppe"
#'
#' @export
group_RKI_timeseries <- function(x, ...) {
  
  .grouping_var <- rlang::ensyms(...)
  
  result <- x %>% 
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
  if (.grouping_var == "Landkreis") {
    ids <- x[c("Landkreis", "IdLandkreis")] %>%
      dplyr::group_by(.data[["Landkreis"]]) %>%
      dplyr::summarise(
        IdLandkreis = max(.data[["IdLandkreis"]])
      ) %>%
      dplyr::ungroup()
    
    result <- result %>%
      left_join(ids, by="Landkreis")
  }
  return(result)
}
