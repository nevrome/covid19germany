#' group_RKI_timeseries
#'
#' Restructures the RKI data to a grouped time series data.frame. Days with no observations are added to make them 
#' explicit. Grouping can be done with one or multiple variables (see parameter \code{...}).
#' Please see the README for more information: \url{https://github.com/nevrome/covid19germany}
#' 
#' @param x data.frame. RKI data as downloaded with \code{\link{get_RKI_timeseries}}
#' @param ... variable names. One or multiple grouping columns of x, so Bundesland, Landkreis, Gender or Age
#'
#' @examples 
#' \donttest{
#' rki_timeseries <- get_RKI_timeseries()
#' 
#' group_RKI_timeseries(rki_timeseries, Bundesland, Gender)
#' }
#'
#' @export
group_RKI_timeseries <- function(x, ...) {
  
  .grouping_var <- rlang::ensyms(...)
  
  res <- x %>% 
    dplyr::select(
      !!!.grouping_var,
      "NumberNewTestedIll", "NumberNewDead", "NumberNewRecovered",
      "MovingCorrectionTestedIll", "MovingCorrectionDead", "MovingCorrectionRecovered",
      "Date"
    ) %>%
    dplyr::group_by(
      !!!.grouping_var, .data[["Date"]]
    ) %>%
    dplyr::summarise(
      NumberNewTestedIll = sum(.data[["NumberNewTestedIll"]], na.rm = T),
      NumberNewDead = sum(.data[["NumberNewDead"]], na.rm = T),
      NumberNewRecovered = sum(.data[["NumberNewRecovered"]], na.rm = T),
      MovingCorrectionTestedIll = sum(.data[["MovingCorrectionTestedIll"]], na.rm = T),
      MovingCorrectionDead = sum(.data[["MovingCorrectionDead"]], na.rm = T),
      MovingCorrectionRecovered = sum(.data[["MovingCorrectionRecovered"]], na.rm = T)
    ) %>%
    dplyr::ungroup()
  
  # add missing days with explicit 0 values
  if (lubridate::is.Date(res$Date)) {
    res <- res %>%
      tidyr::complete(
        tidyr::nesting(!!!.grouping_var),
        Date = tidyr::full_seq(.data[["Date"]], 1),
        fill = list(
          NumberNewTestedIll = 0, NumberNewDead = 0, NumberNewRecovered = 0,
          MovingCorrectionTestedIll = 0, MovingCorrectionDead = 0, MovingCorrectionRecovered = 0
        )
      )
  }
  
  res <- res %>% dplyr::group_by(
      !!!.grouping_var
    ) %>%
    dplyr::mutate(
      CumNumberTestedIll = cumsum(.data[["NumberNewTestedIll"]]),
      CumNumberDead = cumsum(.data[["NumberNewDead"]]),
      CumNumberRecovered = cumsum(.data[["NumberNewRecovered"]]),
      CumMovingCorrectionTestedIll = cumsum(.data[["MovingCorrectionTestedIll"]]),
      CumMovingCorrectionDead = cumsum(.data[["MovingCorrectionDead"]]),
      CumMovingCorrectionRecovered = cumsum(.data[["MovingCorrectionRecovered"]])
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
