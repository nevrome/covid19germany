#' plot_RKI_timeseries
#'
#' @param x data.frame. RKI data as downloaded with \code{\link{get_RKI_timeseries}}
#' @param grouping_var character. "Bundesland", "Landkreis", "Geschlecht", "Altersgruppe"
#' @param type character. Counter type
#' @param label logical
#'
#' @export
plot_RKI_timeseries <- function(x, grouping_var = "Bundesland", type = "KumAnzahlFall", label = T) {

  x <- group_RKI_timeseries(x, !!grouping_var)
  
  p <- x %>%
    tidyr::pivot_longer(cols = tidyselect::contains("Anzahl"), names_to = "Zaehler", values_to = "Anzahl") %>%
    dplyr::filter(.data[["Zaehler"]] == type) %>%
    dplyr::mutate(label = dplyr::if_else(.data[["Meldedatum"]] == (max(x$Meldedatum) - 5*24*60*60), as.character(.data[[grouping_var]]), NA_character_)) %>%
    ggplot2::ggplot(
      ggplot2::aes_string(
        "Meldedatum", "Anzahl", 
        color = grouping_var, group = grouping_var,
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

  return(p)
}
