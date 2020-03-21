library(magrittr)

rki <- covid19germany::get_RKI_timeseries()

x <- group_RKI_timeseries(rki, "Bundesland", "Landkreis")

plot_RKI_timeseries(rki, "Geschlecht", "KumAnzahlTodesfall")
