library(ggplot2)
library(magrittr)

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
ggsave("img/daily_numbers.jpg")

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
ggsave("img/cumul_numbers.jpg")

