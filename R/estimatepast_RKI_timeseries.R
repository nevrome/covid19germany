#' estimatepast_RKI_timeseries
#'
#' This function implements two sequential methods to estimate the real number of infected based on the current 
#' cumulative death count as presented by Tomas Pueyo in this 
#' (\url{https://medium.com/@tomaspueyo/coronavirus-act-today-or-people-will-die-f4d3d9cd99ca}) blog post. 
#' 
#' \emph{HochrechnungInfektionennachToden}, the actual number of infected, is calculated with the current 
#' cumulative number of deaths \strong{KumAnzahlTodesfall}, the death rate \strong{prop_death} and the average number 
#' of days \strong{mean_days_until_death} from infection to death (in case of death). 
#' This approach only allows to estimate values at least \strong{mean_days_until_death} days in the past. 
#' \emph{HochrechnungDunkelziffer} employs \emph{HochrechnungInfektionennachToden} to estimate the number of actually 
#' infected people beyond the \strong{mean_days_until_death} threshold with a simple exponential growth model considering
#' \strong{doubling_time}.
#' With \emph{HochrechnungDunkelziffer} and \strong{prop_death} we can calculate an expected number of deaths
#' \emph{HochrechnungTodenachDunkelziffer}.
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
          HochrechnungInfektionennachToden = dplyr::lead(.data[["KumAnzahlTodesfall"]], mean_days_until_death - 1) / 
            prop_death,
          HochrechnungDunkelziffer = dplyr::lag(.data[["HochrechnungInfektionennachToden"]], mean_days_until_death - 1) * 
            (2^(mean_days_until_death/doubling_time)),
          HochrechnungTodenachDunkelziffer = dplyr::lag(.data[["HochrechnungDunkelziffer"]], mean_days_until_death - 1) * 
            prop_death
        )
    }
  ) %>%
    dplyr::bind_rows()

}
