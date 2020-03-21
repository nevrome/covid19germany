#' group_RKI_timeseries
#'
#' @param x data.frame. RKI data as downloaded with \code{\link{get_RKI_timeseries}}
#' @param grouping_var character. "Bundesland", "Landkreis", "Geschlecht", "Altersgruppe"
#'
#' @export
group_RKI_timeseries <- function(x, grouping_var) {
  
  grouping_var <- rlang::ensym(grouping_var)
  
  x %>% 
    dplyr::select(
      !!grouping_var, "AnzahlFall", "AnzahlTodesfall", "Meldedatum"
    ) %>% 
    dplyr::group_by(
      !!grouping_var, .data[["Meldedatum"]]
    ) %>%
    dplyr::summarise(
      AnzahlFall = sum(AnzahlFall),
      AnzahlTodesfall = sum(AnzahlTodesfall)
    ) %>%
    dplyr::ungroup() %>%
    tidyr::complete(
      tidyr::nesting(!!grouping_var),
      Meldedatum = tidyr::full_seq(Meldedatum, 24*60*60),
      fill = list(AnzahlFall = 0, AnzahlTodesfall = 0)
    ) %>% dplyr::group_by(
      !!grouping_var
    ) %>%
    dplyr::mutate(
      KumAnzahlFall = cumsum(AnzahlFall),
      KumAnzahlTodesfall = cumsum(AnzahlTodesfall)
    ) %>%
    dplyr::ungroup()
  
}
