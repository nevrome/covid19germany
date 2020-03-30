#' estimatepast_RKI_timeseries
#'
#' This function implements two sequential methods to estimate the real number of infected based on the current 
#' cumulative death count as presented by Tomas Pueyo in this 
#' (\url{https://medium.com/@tomaspueyo/coronavirus-act-today-or-people-will-die-f4d3d9cd99ca}) blog post. 
#' 
#' \emph{EstimationCumNumberIllPast}, the actual number of infected, is calculated with the current 
#' cumulative number of deaths \strong{CumNumberDead}, the death rate \strong{prop_death} and the average number 
#' of days \strong{mean_days_until_death} from infection to death (in case of death). 
#' This approach only allows to estimate values at least \strong{mean_days_until_death} days in the past. 
#' \emph{EstimationCumNumberIllPresent} employs the last value in \emph{EstimationCumNumberIllPast} to estimate the number 
#' of actually infected people beyond the \strong{mean_days_until_death} threshold with a simple exponential growth model considering
#' \strong{doubling_time}.
#' With \emph{EstimationCumNumberIllPast}, \emph{EstimationCumNumberIllPresent} and \strong{prop_death} we can calculate an 
#' expected number of deaths \emph{EstimationCumNumberDead}.
#'
#' @param x data.frame. RKI data as downloaded with \code{\link{get_RKI_timeseries}}
#' @param ... variable names. One or multiple grouping columns of x, so Bundesland, Landkreis, Gender or Age
#' @param prop_death numeric. Probability of death
#' @param mean_days_until_death integer. Mean number of days from infection to death (in case of death)
#' @param doubling_time numeric. Mean number of days for the number of infected to double
#' 
#' @examples
#' rki_timeseries <- get_RKI_timeseries()
#' 
#' estimatepast_RKI_timeseries(
#'   rki_timeseries, 
#'   prop_death = 0.01, mean_days_until_death = 17, doubling_time = 4
#' )
#' 
#' estimatepast_RKI_timeseries(
#'   rki_timeseries, Bundesland, Gender, 
#'   prop_death = 0.03, mean_days_until_death = 17, doubling_time = 3
#' )
#'
#' @export
estimatepast_RKI_timeseries <- function(x, ..., prop_death, mean_days_until_death, doubling_time) {
  
  grouped_x <- group_RKI_timeseries(x, ...) %>%
    dplyr::group_split(...)
  
  lapply(
    grouped_x,
    function(y) {
      y %>%
        dplyr::mutate(
          EstimationCumNumberIllPast = dplyr::lead(.data[["CumNumberDead"]], mean_days_until_death - 1) / 
            prop_death,
          EstimationCumNumberIllPresent = c(
            rep(NA, length(.data[["EstimationCumNumberIllPast"]]) - (mean_days_until_death)),
            max(.data[["EstimationCumNumberIllPast"]], na.rm = T) * 2^((0:(mean_days_until_death - 1))/doubling_time)
          ),
          EstimationCumNumberDead = dplyr::lag(c(
            .data[["EstimationCumNumberIllPast"]][
              1:(length(.data[["EstimationCumNumberIllPast"]]) - mean_days_until_death)
            ],
            .data[["EstimationCumNumberIllPresent"]][
              (length(.data[["EstimationCumNumberIllPresent"]]) - (mean_days_until_death - 1)):length(.data[["EstimationCumNumberIllPresent"]]) 
            ]
          ), mean_days_until_death - 1) * prop_death
        )
    }
  ) %>%
    dplyr::bind_rows()

}
