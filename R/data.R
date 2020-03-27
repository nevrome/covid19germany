#' hospital_beds
#'
#' Source: \url{http://www.gbe-bund.de/gbe10/f?f=328::Intensivstation}, 
#' Please see the README for more information: \url{https://github.com/nevrome/covid19germany}
#'
#' @format A data frame with 16 rows and 7 variables.
#' \itemize{
#'   \item \bold{Bundesland}
#'   \item \bold{NumberHospital}
#'   \item \bold{NumberHospitalwithICU}
#'   \item \bold{NumberICUBed}
#'   \item \bold{NumberDaysICUBedinUse}
#'   \item \bold{NumberICUCase}
#'   \item \bold{NumberICUCasewithRespirator}
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
#'   \item \bold{AreaKm2}
#'   \item \bold{PopulationTotal}
#'   \item \bold{PopulationMale}
#'   \item \bold{PopulationFemale}
#'   \item \bold{PopulationperKm2}
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
#'   \item \bold{AreaKm2}
#'   \item \bold{PopulationTotal}
#'   \item \bold{PopulationMale}
#'   \item \bold{PopulationFemale}
#'   \item \bold{PopulationperKm2}
#' }
#'
#' @family context_data
#'
#' @name ew_kreise
NULL

#' ew_alter
#' 
#' Source: \url{https://www-genesis.destatis.de/genesis/online}, 
#' Licence: Deutschland 2.0, 
#' Please see the README for more information: \url{https://github.com/nevrome/covid19germany}
#' 
#' @format A data frame with 6 rows and 4 variables.
#' \itemize{
#'   \item \bold{Age}
#'   \item \bold{PopulationTotal}
#'   \item \bold{PopulationMale}
#'   \item \bold{PopulationFemale}
#' }
#'
#' @family context_data
#'
#' @name ew_alter
NULL
