
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
  df2 = ww_read_sensorlog(file, robust = TRUE, verbose = 2)
  testthat::expect_true(is.data.frame(df2))
  df$file = NULL
  df2$file = NULL
  testthat::expect_equal(df, df2)
})

