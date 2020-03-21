library(magrittr)

rki <- covid19germany::get_RKI_timeseries()

group_RKI_timeseries(rki, "Bundesland") %>% View()

