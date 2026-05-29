test_has_name = function(x, which) {
  testthat::expect_true(
    assertthat::has_name(
      x,
      which
    )
  )
}
