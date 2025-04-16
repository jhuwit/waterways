
test_that("read_sensorlog works", {
  file = ww_example_sensorlog_file()
  testthat::expect_true(assertthat::is.readable(file))
  df = ww_read_sensorlog(file)
  testthat::expect_true(is.data.frame(df))
  testthat::expect_true(nrow(df) > 0)

  test_has_name(
      df,
      c("time", "timestamp", "lat", "lon", "speed")
    )
  testthat::expect_equal(
    mean(df$lat), 39.2974535237175
  )
})

