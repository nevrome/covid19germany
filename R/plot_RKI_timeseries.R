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
#' \donttest{
#' rki_timeseries <- get_RKI_timeseries()
#' 
#' plot_RKI_timeseries(rki_timeseries, "Gender", "CumNumberTestedIll")
#' }
#'
#' @export
plot_RKI_timeseries <- function(x, group = "Bundesland", type = "CumNumberTestedIll", label = T, logy = F) {

  check_if_packages_are_available("ggplot2")
  
  if (is.na(group)) {
    x <- group_RKI_timeseries(x)
  } else {
    x <- group_RKI_timeseries(x, !!group)
  }
  
  prep_data <- x %>%
    tidyr::pivot_longer(cols = tidyselect::contains("Number"), names_to = "Counter", values_to = "Number") %>%
    dplyr::filter(.data[["Counter"]] == type)
    
  if (is.na(group)) {
    p <- prep_data %>%
      ggplot2::ggplot(
      ggplot2::aes_string(
        "Date", "Number"
      )
    )
  } else {
    p <- prep_data %>%
      ggplot2::ggplot(
        ggplot2::aes_string(
          "Date", "Number", 
          color = group, fill = group, group = group, label = group
        )
      )
  }
  
  # parse title
  title <- dplyr::case_when(
    type == "NumberNewTestedIll" ~ "Number of new confirmed cases", 
    type == "NumberNewDead" ~ "Number of new deaths", 
    type == "CumNumberTestedIll" ~ "Total number of confirmed cases", 
    type == "CumNumberDead" ~ "Total number of deaths"
  )
  title <- paste0(Sys.Date(), ": ", title)
  
  p <- p +
    ggplot2::ggtitle(title) +
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
