library(magrittr)

rki <- covid19germany::get_RKI_timeseries()

rki_timeseries_landkreis <- group_RKI_timeseries(rki, "Landkreis")

plot_RKI_timeseries(rki, "Geschlecht", "KumAnzahlTodesfall", logy = T)


####

library(magrittr)
library(covid19germany)
library(ggplot2)

rki <- covid19germany::get_RKI_timeseries()

min_doubling_time <- function(x) {
  es <- estimatepast_RKI_timeseries(rki, prop_death = 0.01, mean_days_until_death = 17, doubling_time = x)
  sum(abs(es$KumAnzahlTodesfall - es$HochrechnungTodenachDunkelziffer), na.rm = T)
}

est_doubling_time <- optim(par = 4, min_doubling_time)$par

de <- rki %>%
  estimatepast_RKI_timeseries(doubling_time = est_doubling_time) %>%
  dplyr::select(-AnzahlFall, -AnzahlTodesfall) %>%
  tidyr::pivot_longer(cols = c(
      "KumAnzahlFall", "HochrechnungInfektionennachToden", "HochrechnungDunkelziffer",
      "KumAnzahlTodesfall", "HochrechnungTodenachDunkelziffer"
    ), names_to = "Anzahltyp"
  )

de %>% 
  dplyr::filter(
    Anzahltyp %in% c("KumAnzahlFall", "HochrechnungInfektionennachToden", "HochrechnungDunkelziffer")
  ) %>%
  ggplot() +
  geom_bar(
    ggplot2::aes(
      Meldedatum, value,
      fill = Anzahltyp
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
  

