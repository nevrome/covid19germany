library(magrittr)

rki <- covid19germany::get_RKI_timeseries()

rki_timeseries_landkreis <- group_RKI_timeseries(rki, "Landkreis")

plot_RKI_timeseries(rki, "Geschlecht", "KumAnzahlTodesfall", logy = T)

####

library(sf)
library(ggplot2)
library(lubridate)
library(magrittr)
library(covid19germany)

# download rki data
rki <- get_RKI_timeseries()

# download a shapefile with geoinformation for the german Landkreise
landkreis_sf <- get_RKI_spatial("Landkreis")

# download and filter rki data to 2020-03-21
rki_202003021_landkreise <- group_RKI_timeseries(rki, "Landkreis") %>% 
  dplyr::filter(Meldedatum == as_datetime("2020-03-21"))

# merge spatial data and rki data
landkreis_sf_COVID19 <- landkreis_sf %>%
  dplyr::left_join(
    rki_202003021_landkreise, by = c("IdLandkreis")
  )

# plot
landkreis_sf_COVID19 %>%
  ggplot() +
  geom_sf(
    aes(fill = KumAnzahlFall)
  ) +
  scale_fill_viridis_c(direction = -1) +
  theme_minimal() +
  ggtitle("Summe der gemeldeten Infektionen pro Landkreis am 21.03.2020") +
  theme(
    axis.title.x = element_blank(),
    axis.title.y = element_blank()
  )
