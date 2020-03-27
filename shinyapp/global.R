
# important ---------------------------------------------------------------

# Here goes all the package loading, data input, preprocessing etc



# r environment -----------------------------------------------------------
if (!("shiny" %in% rownames(installed.packages()))) install.packages("shiny")
if (!("tidyverse" %in% rownames(installed.packages()))) install.packages("tidyverse")
if (!("lubridate" %in% rownames(installed.packages()))) install.packages("lubridate")

library(shiny)
library(tidyverse)
library(lubridate)
library(covid19germany)
library(scales)




# import data -------------------------------------------------------------

rki_df <- get_RKI_timeseries()

# preprocess data ---------------------------------------------------------

rki_pre_df <- rki_df %>%
            arrange(-desc(Date))

