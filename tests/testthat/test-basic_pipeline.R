context("test of all functions with an arbitrary setting")

rki_spatial <- get_RKI_spatial("Bundesland")
rki_timeseries <- get_RKI_timeseries()
vac_ts <- covid19germany::get_RKI_vaccination_timeseries()

test_that("everything works at least generally", {
  expect_s3_class(rki_spatial, "sf")
  expect_s3_class(rki_timeseries, "data.frame")
  expect_s3_class(vac_ts, "data.frame")
  expect_s3_class(
    rki_timeseries %>% group_RKI_timeseries(),
    "data.frame"
  )
  expect_silent(
    rki_timeseries %>% plot_RKI_timeseries()
  )
  expect_s3_class(
    rki_timeseries %>% 
      estimatepast_RKI_timeseries(
        ., 
        prop_death = 0.01, 
        mean_days_until_death = 17, 
        doubling_time = 10
      ),
    "data.frame"
  )
})

