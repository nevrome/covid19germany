#' plot_RKI_add_modelpredictions
#'
#' Add a prediction using exponential regressoin to an existing plot created
#' with \code{\link{plot_RKI_timeseries}}.
#' Please see the README for more information: \url{https://github.com/nevrome/covid19germany}
#'
#' @param gg ggplot. A plot created with \code{\link{plot_RKI_timeseries}}
#' @param n_days_future numeric. Number of days to predict into future.
#' @param restrict logical. Should the calibration of the regression model be
#' restricted to the time when cases started to increase rapidly? Restricting
#' the calibration period increases the fit of the model.
#' @examples 
#' rki_timeseries <- get_RKI_timeseries()
#' 
#' p <- plot_RKI_timeseries(rki_timeseries, "Geschlecht", "KumAnzahlFall")
#'
#' plot_RKI_add_modelpredictions(p)
#'
#' @export
plot_RKI_add_modelpredictions <- function(gg, n_days_future = 3, restrict = T){
  
  grouping_var <- gg$mapping$group %>%
                  as.character() %>% .[2]
  
  # define data with model prediction
  df <- gg$data %>% 
    dplyr::group_by_at(vars(grouping_var %>% as.name())) %>% 
    dplyr::mutate(logAnzahl = ifelse(
                                .data[["Anzahl"]]==0, 0,
                                .data[["Anzahl"]] %>% log)) %>% 
    tidyr::nest() %>%
    # fit lm and predict
    dplyr::mutate(
            model = purrr::map2(data, restrict, fit_mod),
            pred = purrr::pmap(list(data, .data[["model"]], n_days_future),
                              mod_prediction))
  
  # def plot
  gg_new <- gg+
    ggplot2::geom_line(
      data = df %>% tidyr::unnest(.data[["pred"]]),
      aes_string(x = "Meldedatum", y = "pred"),
      color = "black", size = 0.2) 
    
  gg_new <- gg_new %>% add_plotstyle()
  
  return(gg_new)
}


#' add_plotstyle
#'
#' Adds a couple of style elements to a ggplot2 object.
#' Please see the README for more information: \url{https://github.com/nevrome/covid19germany}
#'
#' @param gg ggplot. A plot created with \code{\link{plot_RKI_timeseries}}
#' @examples 
#' gg <- plot_RKI_timeseries(rki_timeseries, "Geschlecht", "KumAnzahlFall")
#'
#' add_plotstyle(gg)
#'
#' @export
add_plotstyle <- function(gg){
  
  gg+
    ggplot2::scale_x_datetime(
              date_breaks = "2 week",
              date_minor_breaks = "1 week")+
    ggplot2::theme_minimal()+
    ggplot2::theme(axis.text.x.bottom = element_text(angle = 45, hjust = 1))+
    ggplot2::labs(x="")

}


#' fit_mod
#'
#' Wraper functoin to fit a log-linear regression model within a nested tibble.
#' Please see the README for more information: \url{https://github.com/nevrome/covid19germany}
#'
#' @param df tibble. A tibble of the data of an RKI timeseries
#' created with \code{\link{plot_RKI_timeseries}}
#' @examples 
#' gg <- plot_RKI_timeseries(rki_timeseries, "Geschlecht", "KumAnzahlFall")
#'
#' df <- gg$data %>% 
#'         group_by_at(vars(grouping_var %>% as.name())) %>% 
#'         mutate(logAnzahl = ifelse(Anzahl==0,0,Anzahl %>% log)) %>% 
#'         nest() %>%
#'         # fit lm and predict
#'         mutate(model = map2(data, restrict, fit_mod),
#'                pred = pmap(list(data, model, n_days_future), mod_prediction)
#'         )
#'
#' @export
fit_mod <- function(df, restrict) {
  
  if (restrict) {
    df <- df %>% 
      filter(.data[["Meldedatum"]] > strptime("2020-03-01", format="%Y-%m-%d"))
  }
  
  df %>%
    lm("logAnzahl ~ Meldedatum", data = .)
}


#' mod_prediction
#'
#' Wrapper function to predict using the model created with \code{\link{fit_mod}}.
#'
#' @param df tibble. A tibble of the data of an RKI timeseries
#' created with \code{\link{plot_RKI_timeseries}}
#' @param mod lm. A linear model created with \code{\link{fit_mod}}.
#' @param n_days_future numeric. The number of days to predict into future.
#' @examples 
#' gg <- plot_RKI_timeseries(rki_timeseries, "Geschlecht", "KumAnzahlFall")
#'
#' df <- gg$data %>% 
#'         group_by_at(vars(grouping_var %>% as.name())) %>% 
#'         mutate(logAnzahl = ifelse(Anzahl==0,0,Anzahl %>% log)) %>% 
#'         nest() %>%
#'         # fit lm and predict
#'         mutate(model = map2(data, restrict, fit_mod),
#'                pred = pmap(list(data, model, n_days_future), mod_prediction)
#'         )
#'
#' @export
mod_prediction <- function(df, mod, n_days_future){
  
  future_df <- 
    tibble(
      Meldedatum = seq(max(df$Meldedatum), by = (3600*24), 
                      length.out = !!n_days_future + 1)[-1]
    )
  
  pred <- 
    df %>% 
    bind_rows(future_df) %>% 
    mutate(label = .data[["label"]][1],
           Zaehler = .data[["Zaehler"]][1],
           pred = exp(predict(mod, newdata = data_frame(Meldedatum)))
    )
  
  return(pred)
}
