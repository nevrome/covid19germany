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

usethis::use_data(hospital_beds, overwrite = T)


