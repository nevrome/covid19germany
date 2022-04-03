# 0.3.2

- fixed an indexing issue in the reading procedure for the vaccination table
- fixed a breaking file name issue in the spatial data download for the Bundesland-level

# 0.3.1

- replaced dplyr with dtplyr in the processing of the cases timeseries, which gives a massive speed boost

# 0.3.0

- updated `get_RKI_vaccination_timeseries()` to include booster vaccination numbers and changed the output column names to better represent the current situation
- adjusted the README figures to the new vaccination data
- more simplification of the already extremely basic unit tests

# 0.2.5

- the spatial datasets were renamed

# 0.2.4

- tiny fix in the plot function to avoid a ggplot2 warning

# 0.2.3

- vaccination dataset was changed again

# 0.2.2

- vaccination dataset was slightly changed yet again and the parser code required a column name change

# 0.2.1

- deleted shinyapp code - never got any updates and there are many good dashboards available

# 0.2.0

- simplified README to make maintenance more easy
- fixed `get_RKI_vaccination_timeseries()` after another change of the source dataset structure - this also forced a rename of the output columns
- three new columns for the `get_RKI_timeseries()` output after intense discussion in #47
