# covid19germany

R Package to download data related to the COVID-19 outbreak in Germany directly into R. This package exists to simplify data analysis.
Test commit. 

Developed in the context of the [#WirvsVirus hackathon](https://www.bundesregierung.de/breg-de/themen/coronavirus/wir-vs-virus-1731968).

## Install 

Install the development version from github with

```
if(!require('devtools')) install.packages('devtools')
devtools::install_github("nevrome/covid19germany")
```
## Functions

- Download RKI data for germany (timeseries): `covid19germany::get_RKI_timeseries()`


