library(magrittr)
library(ggplot2)

rki <- covid19germany::get_RKI_timeseries(cache = F) %>% 
  dplyr::filter(
    Date >= lubridate::as_datetime("2020-02-24")
  )

rki_grouped <- group_RKI_timeseries(rki, Bundesland)

rki_grouped %>%
  ggplot() +
  geom_area(
    aes(Date, CumNumberDead, fill = Bundesland, group = Bundesland),
    color = "white", size = 0.3
  ) +
  scale_y_continuous(labels = scales::comma) +
  ggtitle("Cumulative number of deaths by Bundesland") + ylab("") + xlab("") +
  theme_minimal() + theme(axis.text = element_text(size = 12))

ggsave("p1.png", plot = last_plot(), "png", "~/Desktop/covid19/", scale = 3, width = 10, height = 4, units = "cm")

rki_grouped %>%
  ggplot() +
  geom_area(
    aes(Date, NumberNewDead, fill = Bundesland, group = Bundesland),
    color = "white", size = 0.3
  ) +
  scale_y_continuous(labels = scales::comma) +
  ggtitle("Number of new daily deaths by Bundesland") + ylab("") + xlab("") +
  theme_minimal() + theme(axis.text = element_text(size = 12))

ggsave("p2.png", last_plot(), "png", "~/Desktop/covid19/", scale = 3, width = 10, height = 4, units = "cm")

rki_grouped %>%
  ggplot() +
  geom_area(
    aes(Date, CumNumberTestedIll, fill = Bundesland, group = Bundesland),
    color = "white", size = 0.3
  ) +
  scale_y_continuous(labels = scales::comma) +
  ggtitle("Cumulative number of tested, positive cases by Bundesland") + ylab("") + xlab("") +
  theme_minimal() + theme(axis.text = element_text(size = 12))

ggsave("p3.png", last_plot(), "png", "~/Desktop/covid19/", scale = 3, width = 10, height = 4, units = "cm")

rki_grouped %>%
  ggplot() +
  geom_area(
    aes(Date, NumberNewTestedIll, fill = Bundesland, group = Bundesland),
    color = "white", size = 0.3
  ) +
  scale_y_continuous(labels = scales::comma) +
  ggtitle("Number of daily tested, positive cases by Bundesland") + ylab("") + xlab("") +
  theme_minimal() + theme(axis.text = element_text(size = 12))

ggsave("p4.png", last_plot(), "png", "~/Desktop/covid19/", scale = 3, width = 10, height = 4, units = "cm")

#### map ####

library(sf)
library(ggplot2)
library(covid19germany)

landkreis_sf <- get_RKI_spatial("Landkreis")

rki_day_landkreise <- group_RKI_timeseries(rki, "Landkreis") %>% 
  dplyr::filter(Date == lubridate::as_datetime("2020-03-28"))

landkreis_sf_COVID19 <- landkreis_sf %>%
  dplyr::left_join(
    rki_day_landkreise, by = c("IdLandkreis")
  ) %>%
  dplyr::left_join(
    covid19germany::ew_kreise, by = c("IdLandkreis")
  ) %>%
  dplyr::mutate(
    CumNumberDeadPopulation = CumNumberDead/PopulationTotal * 100000,
    CumNumberTestedIllPopulation = CumNumberTestedIll/PopulationTotal * 100000
  )

m1a <- landkreis_sf_COVID19 %>%
  ggplot() +
  geom_sf(aes(fill = CumNumberDead), size = 0) +
  scale_fill_viridis_c(direction = -1, option = "plasma") +
  theme_minimal() +
  ggtitle("Cumulative number of deaths (28.03.2020)") +
  theme(
    axis.title = element_blank(),
    axis.text = element_blank(),
    panel.grid = element_blank(),
    legend.title = element_blank()
  )

m1b <- landkreis_sf_COVID19 %>%
  ggplot() +
  geom_sf(aes(fill = CumNumberTestedIll), size = 0) +
  scale_fill_viridis_c(direction = -1, option = "plasma") +
  theme_minimal() +
  ggtitle("Cumulative number of tested, positive cases (28.03.2020)") +
  theme(
    axis.title = element_blank(),
    axis.text = element_blank(),
    panel.grid = element_blank(),
    legend.title = element_blank()
  )

map1 <- cowplot::plot_grid(m1a, m1b, align = "hv", ncol = 2)
cowplot::ggsave2("map1.png", map1, "png", "~/Desktop/covid19/", scale = 3, width = 10, height = 4, units = "cm")

m2a <- landkreis_sf_COVID19 %>%
  ggplot() +
  geom_sf(aes(fill = CumNumberDeadPopulation), size = 0) +
  scale_fill_viridis_c(direction = -1, option = "plasma") +
  theme_minimal() +
  ggtitle("Deaths by 100,000 inhabitants (28.03.2020)") +
  theme(
    axis.title = element_blank(),
    axis.text = element_blank(),
    panel.grid = element_blank(),
    legend.title = element_blank()
  )

m2b <- landkreis_sf_COVID19 %>%
  ggplot() +
  geom_sf(aes(fill = CumNumberTestedIllPopulation), size = 0) +
  scale_fill_viridis_c(direction = -1, option = "plasma") +
  theme_minimal() +
  ggtitle("Tested, positive cases by 100,000 inhabitants (28.03.2020)") +
  theme(
    axis.title = element_blank(),
    axis.text = element_blank(),
    panel.grid = element_blank(),
    legend.title = element_blank()
  )

map2 <- cowplot::plot_grid(m2a, m2b, align = "hv", ncol = 2)
cowplot::ggsave2("map2.png", map2, "png", "~/Desktop/covid19/", scale = 3, width = 10, height = 4, units = "cm")
