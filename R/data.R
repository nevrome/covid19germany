#' hospital_beds
#'
#' Source: http://www.gbe-bund.de/oowa921-install/servlet/oowa/aw92/dboowasys921.xwdevkit/xwd_init?gbe.isgbetol/xs_start_neu/&p_aid=3&p_aid=9883226&nummer=841&p_sprache=D&p_indsp=-&p_aid=54727719
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
#' For further information about the values see the documentation on http://www.gbe-bund.de/
#'
#' @family context_data
#'
#' @name hospital_beds
NULL
#' ew_laender
#' 
#' Source: https://www.destatis.de/DE/Themen/Laender-Regionen/Regionales/Gemeindeverzeichnis/Administrativ/04-kreise.html
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
#' For further information about the values see the documentation on https://www.destatis.de
#'
#' @family context_data
#'
#' @name ew_laender
NULL
#' ew_kreise
#' 
#' Source: https://www.destatis.de/DE/Themen/Laender-Regionen/Regionales/Gemeindeverzeichnis/Administrativ/04-kreise.html
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
#' For further information about the values see the documentation on https://www.destatis.de
#'
#' @family context_data
#'
#' @name ew_kreise
NULL