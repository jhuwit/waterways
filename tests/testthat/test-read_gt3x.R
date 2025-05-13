path = ww_example_gt3x_file()
test_that("ww_read_gt3x works", {
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

test_that("ww_calculate_counts works", {

  ac = ww_read_gt3x(path, verbose = TRUE)

  counts = ww_calculate_counts(ac)
  testthat::expect_named(
    counts,
    c("time", "axis1", "axis2",  "axis3", "counts"
    ))
  testthat::expect_silent({
    counts2 = ww_calculate_counts(ac, verbose = FALSE)
  })
  wear = ww_calculate_nonwear(counts)
  testthat::expect_named(
    wear,
    c("time", "wear")
    )
  wear2 = ww_calculate_wear(counts)
  testthat::expect_equal(
    wear,
    wear2
  )
  testthat::expect_true(is.logical(wear$wear))
  result = dplyr::full_join(counts, wear, by = "time") %>%
    dplyr::mutate(wear = ifelse(is.na(wear), FALSE, wear))
  result_proc = ww_process_gt3x(
    path
  )
  testthat::expect_equal(
    result,
    result_proc
  )


})
