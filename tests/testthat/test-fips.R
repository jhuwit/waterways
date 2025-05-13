test_that("ww_fips15 works", {
  res = ww_fips15(24, 510, 60400)
  testthat::expect_equal(
    res,
    "24510060400"
  )
  res = ww_fips15(24, 510, 60400, block = 2002)
  testthat::expect_equal(
    res,
    "245100604002002"
  )
  res  = ww_fips12(24, 510, 60400, block = 2002)
  testthat::expect_equal(
    res,
    "245100604002"
  )
})
