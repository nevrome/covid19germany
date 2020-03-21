library(magrittr)

rki <- covid19germany::get_RKI_timeseries()

rki_grouped <- rki %>% 
  dplyr::group_by(
    Bundesland,
    Meldedatum
  ) %>%
  dplyr::summarise(
    cases = sum(AnzahlFall),
    deaths = sum(AnzahlTodesfall)
  ) %>%
  dplyr::ungroup()

rki_grouped_filled <- tidyr::complete(
  rki_grouped, 
  Bundesland = Bundesland,
  Meldedatum = tidyr::full_seq(Meldedatum, 24*60*60),
  fill = list(cases = 0, deaths = 0)
)

rki_grouped_filled_cum <- rki_grouped_filled %>%
  dplyr::group_by(Bundesland) %>%
  dplyr::mutate(
    cumcases = cumsum(cases),
    cumdeaths = cumsum(deaths)
  ) %>%
  dplyr::ungroup()



