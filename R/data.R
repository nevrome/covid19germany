#' hospital_beds
#'
#' Source: \url{http://www.gbe-bund.de/gbe10/f?f=328::Intensivstation}, 
#' Please see the README for more information: \url{https://github.com/nevrome/covid19germany}
#'
#' @format A data frame with 16 rows and 7 variables.
#' \itemize{
#'   \item \bold{Bundesland}
#'   \item \bold{AnzahlKrankenhaeuser}
#'   \item \bold{AnzahlKrankenhaeusermitIntensiv}
#'   \item \bold{AnzahlBettenIntensiv}
#'   \item \bold{AnzahlBelegungstageIntensiv}
#'   \item \bold{AnzahlBehandlungsfaelleIntensiv}
#'   \item \bold{AnzahlBehandlungsfaelleIntensivmitBeatmung}
#' }
#'
#' @family context_data
#'
#' @name hospital_beds
NULL

#' ew_laender
#' 
#' Source: \url{https://www.destatis.de/DE/Themen/Laender-Regionen/Regionales/Gemeindeverzeichnis/Administrativ/04-kreise.html}, 
#' Licence: Deutschland 2.0, 
#' Please see the README for more information: \url{https://github.com/nevrome/covid19germany}
#' 
#' @format A data frame with 16 rows and 6 variables.
#' \itemize{
#'   \item \bold{Bundesland}
#'   \item \bold{FlaecheKm2}
#'   \item \bold{EwGesamt}
#'   \item \bold{EwMaennlich}
#'   \item \bold{EwWeiblich}
#'   \item \bold{EwProKm2}
#' }
#'
#' @family context_data
#'
#' @name ew_laender
NULL

#' ew_kreise
#' 
#' Source: \url{https://www.statistikportal.de/de/bevoelkerung/flaeche-und-bevoelkerung}, 
#' Licence: Deutschland 2.0, 
#' Please see the README for more information: \url{https://github.com/nevrome/covid19germany}
#' 
#' @format A data frame with 401 rows and 8 variables.
#' \itemize{
#'   \item \bold{IdLandkreis}
#'   \item \bold{Landkreis}
#'   \item \bold{NUTS3}
#'   \item \bold{FlaecheKm2}
#'   \item \bold{EwGesamt}
#'   \item \bold{EwMaennlich}
#'   \item \bold{EwWeiblich}
#'   \item \bold{EwProKm2}
#' }
#'
#' @family context_data
#'
#' @name ew_kreise
NULL
