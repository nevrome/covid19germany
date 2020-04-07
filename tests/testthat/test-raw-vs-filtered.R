context("test of functions with raw or filtered output")

rki_timeseries <- get_RKI_timeseries()
raw_timeseries <- get_RKI_timeseries(raw_only=T)

test_that("raw downloads give something else than filtered downloads", {
  expect_s3_class(
    rki_timeseries,
    "data.frame"
  )
  expect_s3_class(
    raw_timeseries,
    "data.frame"
  )
  expect(
    length(rki_timeseries) <= length(raw_timeseries),
    sprintf("rki_timeseries has length %i !<= %i from raw.",
            length(rki_timeseries),
            length(raw_timeseries))
  )
})

