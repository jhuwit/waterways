testthat::test_that("epa_walkability works", {
  testthat::skip_if_not_installed("arcgislayers")
  # testthat::skip_if_offline()
  res = ww_epa_walkability(c("240054519002", "240054026041", "245102303002"))
  testthat::expect_s3_class(
    res, "sf"
  )
  test_has_name(
    res,
    c("GEOID10", "NatWalkInd", "cat_walk_index")
  )
})
