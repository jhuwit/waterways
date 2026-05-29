#' @inherit actiread::acti_read_gt3x
#' @export
#' @examples
#' path = ww_example_gt3x_file()
#' ac = ww_read_gt3x(path, verbose = FALSE)
ww_read_gt3x = function(
    path,
    asDataFrame = TRUE,
    imputeZeroes = TRUE,
    verbose = TRUE,
    ...,
    fill_zeroes = TRUE,
    apply_tz = TRUE,
    check_attributes = TRUE,
    tz = "GMT"
) {
  data = actiread::acti_read_gt3x(
    path = path,
    asDataFrame = asDataFrame,
    imputeZeroes = imputeZeroes,
    verbose = verbose,
    ...,
    fill_zeroes = fill_zeroes,
    apply_tz = apply_tz,
    check_attributes = check_attributes,
    tz = tz
  )
  data
}

#' @inherit actiread::acti_info_gt3x
#' @export
ww_info_gt3x = actiread::acti_info_gt3x

