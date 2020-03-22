#' plot_RKI_timeseries
#'
#' Simple plotting function for the RKI data.
#' Please see the README for more information: \url{https://github.com/nevrome/covid19germany}
#'
#' @param x data.frame. RKI data as downloaded with \code{\link{get_RKI_timeseries}}
#' @param group character. Grouping of the underlying timeseries. One of: "Bundesland", "Landkreis", "Geschlecht", "Altersgruppe". See \code{\link{group_RKI_timeseries}} for more information
#' @param type character. Type of count information. One of: "AnzahlFall", "AnzahlTodesfall", "KumAnzahlFall", "KumAnzahlTodesfall"
#' @param label logical. Should labels be added?
#' @param logy logical. Should the y-axis be log10-scaled?
#'
#' @examples 
#' rki_timeseries <- get_RKI_timeseries()
#' 
#' plot_RKI_timeseries(rki_timeseries, "Geschlecht", "KumAnzahlFall")
#'
#' @export
plot_RKI_timeseries <- function(x, group = "Bundesland", type = "KumAnzahlFall", label = T, logy = F) {

  x <- group_RKI_timeseries(x, !!group)
  
  p <- x %>%
    tidyr::pivot_longer(cols = tidyselect::contains("Anzahl"), names_to = "Zaehler", values_to = "Anzahl") %>%
    dplyr::filter(.data[["Zaehler"]] == type) %>%
    dplyr::mutate(label = dplyr::if_else(.data[["Meldedatum"]] == (max(x$Meldedatum) - 5*24*60*60), as.character(.data[[group]]), NA_character_)) %>%
    ggplot2::ggplot(
      ggplot2::aes_string(
        "Meldedatum", "Anzahl", 
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
