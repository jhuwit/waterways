file = ww_example_sensorlog_file()
df = ww_read_sensorlog(file)
geo = structure(list(
  address = "615 N Wolfe St, Baltimore MD", lat = 39.297622492942,
  long = -76.590753361728), class = c("tbl_df", "tbl", "data.frame"
  ), row.names = c(NA, -1L))
lat = geo$lat
lon = geo$long

testthat::test_that("ww_process_sensorlog works", {

  testthat::expect_error({
    ww_process_sensorlog(df, check_data = TRUE, tz = "GMT")
  }, regexp = "anyDuplicated")
  result = ww_process_sensorlog(df, check_data = FALSE, tz = "GMT")
  test_has_name(
    result,
    c("time", "timestamp", "distance", "distance_traveled", "is_within_home")
  )
  testthat::expect_true(
    all(is.na(result$distance))
  )
  minute = ww_minute_sensorlog(result)
  testthat::expect_true(
    all(as.numeric(diff(minute$time, units = "mins")) == 1)
  )
  out = ww_summarize_sensorlog(result)
  testthat::expect_true(
    nrow(out) == 1
  )

  result$distance = NULL
  result$lat_zero = result$lon_zero = NULL
  result$is_within_home = NULL
  testthat::expect_no_error({
    out = ww_summarize_sensorlog(result)
  })
})




testthat::test_that("ww_process_sensorlog works with a lat/lon", {

  result1 = ww_process_sensorlog(df, check_data = FALSE, tz = "GMT",
                                 expected_timezone = "America/New_York",
                                 lat = lat, lon = lon)

  result = ww_process_sensorlog(df, check_data = FALSE, tz = "GMT",
                                lat = lat, lon = lon)
  testthat::expect_equal(result1, result)
  test_has_name(
    result,
    c("time", "timestamp", "distance", "distance_traveled", "is_within_home")
  )
  testthat::expect_true(
    !anyNA(result$distance)
  )
  testthat::expect_true(
    all(result$is_within_home)
  )
  minute = ww_minute_sensorlog(result)
  testthat::expect_true(
    all(as.numeric(diff(minute$time, units = "mins")) == 1)
  )
  testthat::expect_equal(
    mean(minute$distance), 73.2948974749109
  )
  out = ww_summarize_sensorlog(result)
  testthat::expect_true(
    nrow(out) == 1
  )
  testthat::expect_equal(
    out$sum_distance, 879.538769698931
  )
  testthat::expect_equal(
    out$max_distance, 73.306135478788576165
  )

  result$time = NULL
  testthat::expect_error({
    ww_summarize_sensorlog(result)
  })

})
