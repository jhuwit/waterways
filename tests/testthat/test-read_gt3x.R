test_that("ww_read_gt3x works", {
  path = ww_example_gt3x_file()
  testthat::expect_true(assertthat::is.readable(path))
  ac = ww_read_gt3x(path, verbose = FALSE)
  testthat::expect_named(
    ac,
    c("time", "X", "Y", "Z")
  )
  testthat::expect_true(
    !anyNA(ac$X)
  )
  testthat::expect_true(
    !anyNA(ac$Y)
  )
  testthat::expect_true(
    !anyNA(ac$Z)
  )
  testthat::expect_equal(
    mean(ac$X), -0.0389739341085271
  )
  testthat::expect_equal(
    lubridate::tz(ac$time), "GMT"
  )
  testthat::expect_equal(
    range(ac$time),
    structure(c(1741715100, 1741722194.9875), class = c("POSIXct",
                                                        "POSIXt"), tzone = "GMT")
    )
})
