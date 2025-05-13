test_that("read_sensorlogger works", {
  file = ww_example_sensorlogger_location_file()
  testthat::expect_true(assertthat::is.readable(file))
  df = ww_read_sensorlogger(file)
  testthat::expect_true(is.data.frame(df))
  testthat::expect_true(nrow(df) > 0)

  file = ww_example_sensorlogger_file()
  testthat::expect_true(assertthat::is.readable(file))

  dfs = ww_read_sensorlogger(file)
  df = dfs$location
  testthat::expect_true(is.data.frame(df))
  testthat::expect_true(nrow(df) > 0)

  test_has_name(
    df,
    c("time", "lat", "lon", "speed")
  )
  testthat::expect_equal(
    mean(df$lat), 39.2974856342069
  )

  testthat::expect_equal(
    range(df$time),
    structure(c(1745877874.25332, 1745877960.23286),
              class = c("POSIXct",
                        "POSIXt"),
              tzone = "UTC")
  )
  out = ww_process_sensorlog(df, apply_tz = FALSE)
})

