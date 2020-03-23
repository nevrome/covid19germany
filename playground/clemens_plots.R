library(magrittr)

rki <- covid19germany::get_RKI_timeseries()

rki_timeseries_landkreis <- group_RKI_timeseries(rki, "Landkreis")

plot_RKI_timeseries(rki, "Geschlecht", "KumAnzahlTodesfall", logy = T)

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
  

