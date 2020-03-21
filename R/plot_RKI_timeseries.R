#' plot_RKI_timeseries
#'
#' @param x data.frame. RKI data as downloaded with \code{\link{get_RKI_timeseries}}
#' @param group character. "Bundesland", "Landkreis", "Geschlecht", "Altersgruppe"
#' @param type character. Counter type
#' @param label logical
#' @param logy logical
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
        color = group, group = group,
        label = "label"
      )
    ) +
    ggplot2::geom_line() +
    ggplot2::guides(
      color = FALSE
    ) +
    ggplot2::ggtitle(type)
  
  if (label) {
    p <- p + ggrepel::geom_label_repel(
        na.rm = TRUE
      )
  }
  
  if (logy) {
    p <- p + ggplot2::scale_y_log10()
  }

  return(p)
}
