library(magrittr)
library(ggplot2)

rki <- covid19germany::get_RKI_timeseries(cache = F) %>% 
  dplyr::filter(
    Date >= lubridate::as_datetime("2020-03-02")
  )

rki_grouped <- covid19germany::group_RKI_timeseries(rki, Bundesland)

p1a <- rki_grouped %>%
  ggplot() +
  geom_area(
    aes(Date, CumNumberDead, fill = Bundesland, group = Bundesland),
    color = "white", size = 0.3
  ) +
  scale_y_continuous(labels = scales::comma) +
  ggtitle("Cumulative number of deaths by Bundesland") + ylab("") + xlab("") +
  theme_minimal() + theme(axis.text = element_text(size = 12)) +
  guides(fill = FALSE)

p1b <- rki_grouped %>%
  ggplot() +
  geom_area(
    aes(Date, CumNumberTestedIll, fill = Bundesland, group = Bundesland),
    color = "white", size = 0.3
  ) +
  scale_y_continuous(labels = scales::comma) +
  ggtitle("Cumulative number of tested, positive cases by Bundesland") + ylab("") + xlab("") +
  theme_minimal() + theme(axis.text = element_text(size = 12), legend.title = element_blank())

p1 <- cowplot::plot_grid(p1a, p1b, align = "h", ncol = 2, rel_widths = c(1, 1.5))
cowplot::ggsave2("p1.png", p1, "png", "~/Desktop/covid19/", scale = 3, width = 10, height = 4, units = "cm")

p2a <- rki_grouped %>%
  ggplot() +
  geom_area(
    aes(Date, NumberNewDead, fill = Bundesland, group = Bundesland),
    color = "white", size = 0.3
  ) +
  scale_y_continuous(labels = scales::comma) +
  ggtitle("Number of new daily deaths by Bundesland") + ylab("") + xlab("") +
  theme_minimal() + theme(axis.text = element_text(size = 12)) +
  guides(fill = FALSE)

p2b <- rki_grouped %>%
  ggplot() +
  geom_area(
    aes(Date, NumberNewTestedIll, fill = Bundesland, group = Bundesland),
    color = "white", size = 0.3
  ) +
  scale_y_continuous(labels = scales::comma) +
  ggtitle("Number of daily tested, positive cases by Bundesland") + ylab("") + xlab("") +
  theme_minimal() + theme(axis.text = element_text(size = 12), legend.title = element_blank())

p2 <- cowplot::plot_grid(p2a, p2b, align = "h", ncol = 2, rel_widths = c(1, 1.5))
cowplot::ggsave2("p2.png", p2, "png", "~/Desktop/covid19/", scale = 3, width = 10, height = 4, units = "cm")

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

#### estimation ####

rki_full <- covid19germany::get_RKI_timeseries(cache = F)

model_grid <- expand.grid(
  prop_death = c(0.01, 0.03, 0.05),
  doubling_time = c(3, 5, 7)
)

est_multi <- lapply(1:nrow(model_grid), function(i) {
  pd <- model_grid$prop_death[i]
  dti <- model_grid$doubling_time[i]
  est <- covid19germany::estimatepast_RKI_timeseries(rki_full, prop_death = pd, mean_days_until_death = 17, doubling_time = dti) %>%
    dplyr::select(-NumberNewTestedIll, -NumberNewDead) %>%
    tidyr::pivot_longer(cols = c(
      "CumNumberTestedIll", "EstimationCumNumberIllPast", "EstimationCumNumberIllPresent",
      "CumNumberDead", "EstimationCumNumberDeadFuture"
    ), names_to = "CountType") %>%
    dplyr::mutate(
      prop_death = pd,
      doubling_time = dti
    )
  return(est)
}) %>% dplyr::bind_rows()

pest1a <- ggplot() +
  geom_line(
    data = est_multi %>% dplyr::filter(CountType == "CumNumberTestedIll", value >= 1) %>% dplyr::select(Date, value) %>% unique,
    mapping = aes(
      Date, value
    ),
    size = 1,
    color = "red"
  ) +
  geom_line(
    data = est_multi %>% dplyr::filter(CountType == "EstimationCumNumberIllPast", value >= 1),
    mapping = aes(
      Date, value, 
      color = as.character(prop_death)
    ),
    size = 1,
    alpha = 0.6
  ) +
  geom_line(
    data = est_multi %>% dplyr::filter(CountType == "EstimationCumNumberIllPresent", value >= 1),
    mapping = aes(
      Date, value, 
      color = as.character(prop_death), linetype = as.character(doubling_time), group = interaction(prop_death, doubling_time)
    ),
    size = 1,
    alpha = 0.6
  ) +
  scale_y_continuous(labels = scales::comma) +
  ggtitle("Estimated number of infected (red: Number of tested and positive individuals)") + ylab("") + xlab("") +
  theme_minimal() +
  guides(color = F, linetype = F) +
  geom_vline(
    aes(xintercept = lubridate::as_datetime(lubridate::today() - lubridate::days(17)))
  ) +
  geom_vline(
    aes(xintercept = lubridate::as_datetime(lubridate::today() - 1)),
    color = "blue"
  )

pest1b <-  ggplot() +
  geom_line(
    data = est_multi %>% dplyr::filter(CountType == "CumNumberTestedIll", value >= 1) %>% dplyr::select(Date, value) %>% unique,
    mapping = aes(
      Date, value
    ),
    size = 1,
    color = "red"
  ) +
  geom_line(
    data = est_multi %>% dplyr::filter(CountType == "EstimationCumNumberIllPast", value >= 1),
    mapping = aes(
      Date, value, 
      color = as.character(prop_death)
    ),
    size = 1,
    alpha = 0.6
  ) +
  geom_line(
    data = est_multi %>% dplyr::filter(CountType == "EstimationCumNumberIllPresent", value >= 1),
    mapping = aes(
      Date, value, 
      color = as.character(prop_death), linetype = as.character(doubling_time), group = interaction(prop_death, doubling_time)
    ),
    size = 1,
    alpha = 0.6
  ) +
  scale_y_log10(labels = scales::comma) +
  ggtitle("") + ylab("") + xlab("") +
  theme_minimal() +
  guides(
    color = guide_legend(title = "Death probability scenarios", keywidth = 5), 
    linetype = guide_legend(title = "Doubling time scenarios", keywidth = 5)
  ) +
  geom_vline(
    aes(xintercept = lubridate::as_datetime(lubridate::today() - lubridate::days(17)))
  ) +
  geom_vline(
    aes(xintercept = lubridate::as_datetime(lubridate::today() - 1)),
    color = "blue"
  )

pest1 <- cowplot::plot_grid(pest1a, pest1b, align = "h", ncol = 2, rel_widths = c(1, 1.5))
cowplot::ggsave2("pest1.png", pest1, "png", "~/Desktop/covid19/", scale = 3, width = 10, height = 4, units = "cm")

pest2a <- ggplot() +
  geom_line(
    data = est_multi %>% dplyr::filter(CountType == "CumNumberDead", value >= 1) %>% dplyr::select(Date, value) %>% unique,
    mapping = aes(
      Date, value
    ),
    size = 1,
    color = "red"
  ) +
  geom_line(
    data = est_multi %>% dplyr::filter(CountType == "EstimationCumNumberDeadFuture", value >= 1) %>% dplyr::select(Date, value, doubling_time) %>% unique,
    mapping = aes(
      Date, value, 
      linetype = as.character(doubling_time), group = doubling_time
    ),
    size = 1,
    alpha = 0.6
  ) +
  scale_y_continuous(labels = scales::comma) +
  ggtitle("Estimated number of future deaths (red: Current cumulative number of deaths)") + ylab("") + xlab("") +
  theme_minimal() +
  guides(color = F, linetype = F) +
  geom_vline(
    aes(xintercept = lubridate::as_datetime(lubridate::today() - lubridate::days(17)))
  ) +
  geom_vline(
    aes(xintercept = lubridate::as_datetime(lubridate::today() - 1)),
    color = "blue"
  )

pest2b <-  ggplot() +
  geom_line(
    data = est_multi %>% dplyr::filter(CountType == "CumNumberDead", value >= 1) %>% dplyr::select(Date, value) %>% unique,
    mapping = aes(
      Date, value
    ),
    size = 1,
    color = "red"
  ) +
  geom_line(
    data = est_multi %>% dplyr::filter(CountType == "EstimationCumNumberDeadFuture", value >= 1) %>% dplyr::select(Date, value, doubling_time) %>% unique,
    mapping = aes(
      Date, value, 
      linetype = as.character(doubling_time), group = doubling_time
    ),
    size = 1,
    alpha = 0.6
  ) +
  scale_y_log10(labels = scales::comma) +
  ggtitle("") + ylab("") + xlab("") +
  theme_minimal() +
  guides(linetype = guide_legend(title = "Doubling time scenarios", keywidth = 5)) +
  geom_vline(
    aes(xintercept = lubridate::as_datetime(lubridate::today() - lubridate::days(17)))
  ) +
  geom_vline(
    aes(xintercept = lubridate::as_datetime(lubridate::today() - 1)),
    color = "blue"
  )

pest2 <- cowplot::plot_grid(pest2a, pest2b, align = "h", ncol = 2, rel_widths = c(1, 1.5))
cowplot::ggsave2("pest2.png", pest2, "png", "~/Desktop/covid19/", scale = 3, width = 10, height = 4, units = "cm")

