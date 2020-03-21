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


usethis::use_data(hospital_beds, overwrite = T)
usethis::use_data(ew_laender, overwrite = T)
usethis::use_data(ew_kreise, overwrite = T)
