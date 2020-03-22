library(ggplot2)
library(magrittr)

data("ew_laender")

dat <- get_RKI_timeseries(cache=F)

group_RKI_timeseries(dat, Bundesland) %>%
  dplyr::filter(Meldedatum > "2020-02-25") %>%
  tidyr::drop_na(Bundesland) %>%
  ggplot() +
  geom_bar(mapping = aes(x = Meldedatum,
                         y = AnzahlFall,
                         fill = Bundesland),
           stat = 'identity') +
  theme_minimal() +
  ggtitle("Gemeldete Infektionen (täglich)") +
  theme(axis.title.x=element_blank(),
        axis.title.y=element_blank())
ggsave("man/figures/daily_numbers.jpg")

group_RKI_timeseries(dat, Bundesland) %>%
  dplyr::filter(Meldedatum > "2020-02-25") %>%
  tidyr::drop_na(Bundesland) %>%
  dplyr::group_by(Bundesland) %>%
  dplyr::mutate(kum_fall = cumsum(AnzahlFall)) %>%
  dplyr::ungroup() %>%
  ggplot() +
  geom_area(mapping = aes(x = Meldedatum,
                          y = kum_fall,
                          fill = Bundesland),
            stat = 'identity',
            na.rm = T) +
  theme_minimal() +
  ggtitle("Gemeldete Infektionen (kumulativ)") +
  theme(axis.title.x=element_blank(),
        axis.title.y=element_blank())
ggsave("man/figures/cumul_numbers.jpg")

group_RKI_timeseries(dat, Bundesland) %>%
  dplyr::left_join(ew_laender, by="Bundesland") %>%
  dplyr::filter(Meldedatum > "2020-02-25") %>%
  tidyr::drop_na(Bundesland) %>%
  dplyr::group_by(Bundesland) %>%
  dplyr::mutate(kum_fall_per100k_ew = cumsum(AnzahlFall) / EwGesamt) %>%
  dplyr::ungroup() %>%
  ggplot() +
  geom_line(mapping = aes(x = Meldedatum,
                          y = kum_fall_per100k_ew,
                          col = Bundesland)) +
  theme_minimal() +
  ggtitle("Gemeldete Infektionen pro 100K Einwohner (kumulativ)") +
  theme(axis.title.x=element_blank(),
        axis.title.y=element_blank())
ggsave("man/figures/cumul_numbers_per_100k.jpg")
