
# important ---------------------------------------------------------------

# Here goes all the package loading, data input, preprocessing etc



# r environment -----------------------------------------------------------
library(shiny)
library(tidyverse)
library(covid19germany)

# import data -------------------------------------------------------------

rki_df <- get_RKI_timeseries()

# preprocess data ---------------------------------------------------------

rki_pre_df <- rki_df %>% arrange(-desc(Date))
