library(magrittr)

rki <- covid19germany::get_RKI_timeseries()

rki_timeseries_landkreis <- group_RKI_timeseries(rki, "Landkreis")

plot_RKI_timeseries(rki, "Geschlecht", "KumAnzahlTodesfall", logy = T)


####

library(magrittr)
library(covid19germany)
library(ggplot2)

rki <- covid19germany::get_RKI_timeseries()
de <- rki %>%
  group_RKI_timeseries() %>%
  dplyr::mutate(
    A_estimation_of_cases_from_later_deaths = c(KumAnzahlTodesfall[17:(length(KumAnzahlTodesfall))], rep(NA, 16)) * 100,
    B_estimation_of_cases_from_A = c(rep(NA, 16), A_estimation_of_cases_from_later_deaths[1:(length(A_estimation_of_cases_from_later_deaths) - 16)]) * 8 
  ) %>%
  dplyr::select(-AnzahlFall, -AnzahlTodesfall) %>%
  tidyr::pivot_longer(cols = c("KumAnzahlFall", "KumAnzahlTodesfall", "A_estimation_of_cases_from_later_deaths", "B_estimation_of_cases_from_A"), names_to = "count")

de %>% ggplot() +
  geom_bar(
    ggplot2::aes(
      Meldedatum, value,
      fill = count
    ),
    stat = "identity",
    position = "dodge"
  ) +
  theme_minimal()

####

library(covid19germany)

rki <- get_RKI_timeseries()
rki_timeseries_bundesland <- group_RKI_timeseries(rki, "Bundesland")

rki_timeseries_bundesland_split <- split(rki_timeseries_bundesland, rki_timeseries_bundesland$Bundesland)

r0_bavaria <- rki_timeseries_bundesland_split$Bayern %$%
  KumAnzahlFall %>%
  EpiEstim::estimate_R(method = "uncertain_si", config = config) %$%
  R

r0_bavaria %>%
  ggplot() +
  geom_line(
    aes(t_start, `Mean(R)`)
  ) +
  geom_ribbon(
    aes(
      x = t_start,
      ymin = `Mean(R)` - `Std(R)`,
      ymax = `Mean(R)` + `Std(R)`
    ),
    alpha = 0.5
  )
  

