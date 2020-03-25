#' estimatepast_RKI_timeseries
#'
#' @param x data.frame. RKI data as downloaded with \code{\link{get_RKI_timeseries}}
#' @param ... variable names. One or multiple grouping columns of x, so Bundesland, Landkreis, Geschlecht or Altersgruppe
#' @param prop_death numeric. Probability of death
#' @param mean_days_until_death integer. Mean number of days from infection to death (in case of death)
#' @param doubling_time numeric. Mean number of days for the number of infected to double
#' 
#' @examples
#' rki_timeseries <- get_RKI_timeseries()
#' 
#' estimatepast_RKI_timeseries(rki_timeseries)
#' estimatepast_RKI_timeseries(rki_timeseries, Bundesland, Geschlecht)
#'
#' @export
estimatepast_RKI_timeseries <- function(x, ..., prop_death = 0.01, mean_days_until_death = 17, doubling_time = 4) {
  
  grouped_x <- group_RKI_timeseries(x, ...) %>%
    dplyr::group_split(...)
  
  lapply(
    grouped_x,
    function(y) {
      y %>%
        dplyr::mutate(
          HochrechnungInfektionennachToden = c(
            .data[["KumAnzahlTodesfall"]][mean_days_until_death:(length(.data[["KumAnzahlTodesfall"]]))],
            rep(NA, mean_days_until_death - 1)
          ) / prop_death
        ) %>%
        dplyr::mutate(
          HochrechnungDunkelziffer = c(
            rep(NA, mean_days_until_death - 1),
            .data[["HochrechnungInfektionennachToden"]][1:(length(.data[["HochrechnungInfektionennachToden"]]) - (mean_days_until_death - 1))]
          ) * (2^(mean_days_until_death/doubling_time))
        ) %>%
        dplyr::mutate(
          HochrechnungTodenachDunkelziffer = c(
            rep(NA, mean_days_until_death - 1),
            .data[["HochrechnungDunkelziffer"]][1:(length(.data[["HochrechnungDunkelziffer"]]) - (mean_days_until_death - 1))]
          ) * prop_death
        )
    }
  ) %>%
    dplyr::bind_rows()

}
