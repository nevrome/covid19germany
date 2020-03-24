hospital_beds <- readr::read_csv(
  "data-raw/hospital_beds.csv",
  col_types = readr::cols(
    AnzahlKrankenhaeuser = readr::col_character(),
    AnzahlKrankenhaeusermitIntensiv = readr::col_integer(),
    AnzahlBettenIntensiv = readr::col_integer(),
    AnzahlBelegungstageIntensiv = readr::col_integer(),
    AnzahlBehandlungsfaelleIntensiv = readr::col_integer(),
    AnzahlBehandlungsfaelleIntensivmitBeatmung = readr::col_integer()
  )
)

ew_laender <- readr::read_delim(
  "data-raw/EW_Laender.csv", delim=";",
  col_types = readr::cols(
    Bundesland = readr::col_character(),
    FlaecheKm2 = readr::col_double(),
    EwGesamt = readr::col_integer(),
    EwMaennlich = readr::col_integer(),
    EwWeiblich = readr::col_integer(),
    EwProKm2 = readr::col_double()
  )
)

ew_kreise <- readr::read_delim(
  "data-raw/EW_Kreise.csv", ";",
  col_types = readr::cols(
    IdLandkreis = readr::col_integer(),
    NameLandkreis = readr::col_character(),
    NUTS3 = readr::col_character(),
    FlaecheKm2 = readr::col_double(),
    EwGesamt = readr::col_integer(),
    EwMaennlich = readr::col_integer(),
    EwWeiblich = readr::col_integer(),
    EwProKm2 = readr::col_double()
  )
)

ew_alter <- readr::read_csv(
  "data-raw/EW_Alter.csv",
  col_types = readr::cols(
    alter = col_double(),
    m = col_double(),
    w = col_double(),
    total = col_double()
  )) %>%
  dplyr::group_by(
    gr = cut(alter, 
      breaks = c(0, 4, 14, 34, 59, 79, 100), 
      labels = c("A00-A04", "A05-A14", "A15-A34", "A35-A59",
                 "A60-A79", "A80+"),
      include.lowest = TRUE)) %>%
  dplyr::summarise(
    EwGesamt = sum(total),
    EwMaennlich = sum(m),
    EwWeiblich = sum(w))  %>%
  dplyr::mutate(Altersgruppe = gr) %>%
  dplyr::select(.data$Altersgruppe, .data$EwGesamt, .data$EwMaennlich, .data$EwWeiblich)




usethis::use_data(hospital_beds, overwrite = TRUE)
usethis::use_data(ew_laender, overwrite = TRUE)
usethis::use_data(ew_kreise, overwrite = TRUE)
usethis::use_data(ew_alter, overwrite = TRUE)
