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
