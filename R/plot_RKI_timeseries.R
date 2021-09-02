#' plot_RKI_timeseries
#'
#' Simple plotting function for the RKI data.
#' Please see the README for more information: \url{https://github.com/nevrome/covid19germany}
#'
#' @param x data.frame. RKI data as downloaded with \code{\link{get_RKI_timeseries}}
#' @param group character. Grouping of the underlying timeseries. One of: "Bundesland", "Landkreis", "Gender", "Age". See \code{\link{group_RKI_timeseries}} for more information
#' @param type character. Type of count information. 
#' One of: "NumberNewTestedIll", "NumberNewDead", "NumberNewRecovered", "CumNumberTestedIll", "CumNumberDead", "CumNumberRecovered"
#' @param label logical. Should labels be added?
#' @param logy logical. Should the y-axis be log10-scaled?
#' @param by_month logical. Should the output plot be grouped by month or by days?
#' @param by_week logical. Deprecated and replaced by by_month
#'
#' @examples 
#' \donttest{
#' rki_timeseries <- get_RKI_timeseries()
#' 
#' plot_RKI_timeseries(rki_timeseries, "Gender", "CumNumberTestedIll")
#' }
#'
#' @export
plot_RKI_timeseries <- function(x, group = "Bundesland", type = "CumNumberTestedIll", label = T, logy = F, by_month = T, by_week = F) {

  check_if_packages_are_available("ggplot2")
  
  # group by month
  if (by_month) {
    x <- x %>% dplyr::group_by(
      month = lubridate::month(.data[["Date"]], label = FALSE), year = lubridate::year(.data[["Date"]]),
      .data[["IdBundesland"]], .data[["Bundesland"]],
      .data[["IdLandkreis"]], .data[["Landkreis"]],
      .data[["Age"]], .data[["Gender"]]
    ) %>% dplyr::summarise(
      dplyr::across(
        tidyselect::one_of(
          "NumberNewTestedIll", "NumberNewDead", "NumberNewRecovered",
          "MovingCorrectionTestedIll", "MovingCorrectionDead", "MovingCorrectionRecovered"
        ),
        function(x) {sum(x, na.rm = T)}
      ),
      .groups = "drop"
    ) %>%
      dplyr::ungroup() %>%
      dplyr::mutate(
        month = formatC(.data[["month"]], width = 2, format = "d", flag = "0")
      ) %>%
      tidyr::unite(
        col = "Date",
        .data[["year"]],
        .data[["month"]]
      )
  }
  
  # group by input grouping variable
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
    type == "NumberNewTestedIll" ~ "Number of confirmed cases", 
    type == "NumberNewDead" ~ "Number of deaths", 
    type == "CumNumberTestedIll" ~ "Total number of confirmed cases", 
    type == "CumNumberDead" ~ "Total number of deaths",
    type == "NumberNewRecovered" ~ "Number of recoverings (estimated)",
    type == "CumNumberRecovered" ~ "Total number of recoverings (estimated)", 
  )
  title <- paste0(Sys.Date(), ": ", title)
  
  p <- p +
    ggplot2::ggtitle(title) +
    ggplot2::theme_minimal() +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 60, vjust = 1, hjust = 1))

  if (!logy) {
    p <- p + 
      ggplot2::geom_bar(stat = "identity")
  } else {
    p <- p + 
      ggplot2::geom_line(stat = "identity") +
      ggplot2::scale_y_log10()
  }
    
  if (!label) {
    p <- p + ggplot2::guides(
      fill = "none",
      color = "none"
    )
  }
  
  p <- p + ggplot2::scale_y_continuous(labels = scales::comma)
  
  return(p)
}
