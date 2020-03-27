#' plot_RKI_timeseries
#'
#' Simple plotting function for the RKI data.
#' Please see the README for more information: \url{https://github.com/nevrome/covid19germany}
#'
#' @param x data.frame. RKI data as downloaded with \code{\link{get_RKI_timeseries}}
#' @param group character. Grouping of the underlying timeseries. One of: "Bundesland", "Landkreis", "Gender", "Age". See \code{\link{group_RKI_timeseries}} for more information
#' @param type character. Type of count information. One of: "NumberNewTestedIll", "NumberNewDead", "CumNumberTestedIll", "CumNumberDead"
#' @param label logical. Should labels be added?
#' @param logy logical. Should the y-axis be log10-scaled?
#'
#' @examples 
#' rki_timeseries <- get_RKI_timeseries()
#' 
#' plot_RKI_timeseries(rki_timeseries, "Gender", "CumNumberTestedIll")
#'
#' @export
plot_RKI_timeseries <- function(x, group = "Bundesland", type = "CumNumberTestedIll", label = T, logy = F) {

  check_if_packages_are_available("ggplot2")
  
  x <- group_RKI_timeseries(x, !!group)
  
  p <- x %>%
    tidyr::pivot_longer(cols = tidyselect::contains("Number"), names_to = "Counter", values_to = "Number") %>%
    dplyr::filter(.data[["Counter"]] == type) %>%
    dplyr::mutate(label = dplyr::if_else(.data[["Date"]] == (max(x$Date) - 5*24*60*60), as.character(.data[[group]]), NA_character_)) %>%
    ggplot2::ggplot(
      ggplot2::aes_string(
        "Date", "Number", 
        color = group, fill = group, group = group,
        label = "label"
      )
    ) +
    ggplot2::ggtitle(type) +
    ggplot2::theme_minimal()

  if (!logy) {
    p <- p + 
      ggplot2::geom_area()
  } else {
    p <- p + 
      ggplot2::geom_line() +
      ggplot2::scale_y_log10()
  }
    
  if (!label) {
    p <- p + ggplot2::guides(
      fill = FALSE,
      color = FALSE
    )
  }
  
  return(p)
}
