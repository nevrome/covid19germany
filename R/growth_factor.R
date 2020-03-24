#' growth_factor_RKI_timeseries
#'
#' Calculate the growth factors (Vervielfaeltigung pro Tag) in RKI
#' data which have been restructered with group_RKI_timeseries(...)
#' before. The function works on any grouping made with
#' group_RKI_timeseries().
#'
#' The growth factor is defined as the 
#'
#' @param .data data.frame. Restructured RKI data
#' @param days integer. Interval of days. Defaults to 1.
#'
#' @examples
#' timeseries <- get_RKI_timeseries()
#'
#' republik <- group_RKI_timeseries(timeseries)
#'
#' wachstum_republik <- growth_factor_RKI_timeseries(republik)
#'
#' mutate(wachstum_republik, Meldedatum = as.Date(Meldedatum)) %>%
#'     ggplot() +
#'     geom_line(aes(x = Meldedatum, y = Wachstumsfaktor)) +
#'     geom_smooth(aes(x = Meldedatum, y = Wachstumsfaktor)) +
#'     scale_x_date(date_breaks = 'week', date_labels = '%b %d\n%a')
#'
#' 
#' bundeslaender <- group_RKI_timeseries(timeseries, Bundesland)
#'
#' wachstum_bundeslaender <- growth_factor_RKI_timeseries(bundeslaender)
#'
#' @export
growth_factor_RKI_timeseries <- function(x, days = 1) {
    
    time_interval <- days * time_of_day

    joining_cols <- base::colnames(x)[
        base::which(! base::colnames(x) %in% base::c(counts_RKI_timeseries, "Meldedatum"))]

    if (base::length(joining_cols) > 0) {
        
        ## we do an inner join, which performs better than cartesian product
        cartesian <- dplyr::inner_join(x, x, by = joining_cols) %>%
            dplyr::filter(Meldedatum.x == Meldedatum.y + time_interval) %>%
            dplyr::mutate(Wachstumsfaktor = KumAnzahlFall.x / KumAnzahlFall.y) %>%
            dplyr::rename(Meldedatum = Meldedatum.x) %>%
            dplyr::select(-matches('.[xy]$'))
        
    } else {

        xx <- x ## new var because crossing won't work on (x, x)
        cartesian <- tidyr::crossing(xx, xx) %>%
            dplyr::filter(Meldedatum == Meldedatum1 + time_interval) %>%
            dplyr::mutate(Wachstumsfaktor = KumAnzahlFall / KumAnzahlFall1) %>%
            dplyr::select(Meldedatum, Wachstumsfaktor)

    }

    ## replace Inf and NaN with NA
    cartesian <- dplyr::mutate_at(cartesian,
                                  "Wachstumsfaktor",
                                  ~base::replace(., !base::is.finite(.), NA))
    
    res <- dplyr::left_join(x, cartesian, by = base::c(joining_cols, "Meldedatum"))

    return(res)

}

#' columnes which count cases
counts_RKI_timeseries <- base::c("AnzahlFall", "AnzahlTodesfall", "KumAnzahlFall", "KumAnzahlTodesfall")

time_of_day <- 86400 # seconds per day
