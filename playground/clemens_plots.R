library(magrittr)

rki <- covid19germany::get_RKI_timeseries()

x <- group_RKI_timeseries(rki, "Bundesland", "Landkreis")

plot_RKI_timeseries(rki, "Geschlecht", "KumAnzahlTodesfall", logy = T)

####

library(magrittr)
library(covid19germany)

# Get RKI data and transform to daily time series, e.g. per "Bundesland" and "Landkreis"
rki <- get_RKI_timeseries()
rki_timeseries_bundesland <- rki %>% group_RKI_timeseries("Bundesland")
rki_timeseries_landkreis <- rki %>% group_RKI_timeseries("Landkreis")

# Join population info to RKI data
rki_timeseries_bundesland <- rki_timeseries_bundesland %>%
  dplyr::left_join(ew_laender, by = "Bundesland")

rki_timeseries_landkreis <- rki_timeseries_landkreis %>%
  dplyr::left_join(ew_kreise, by = "IdLandkreis")

# Join hospital info to RKI data
rki_timeseries_bundesland <- rki_timeseries_bundesland %>%
  dplyr::left_join(hospital_beds, by = "Bundesland")
