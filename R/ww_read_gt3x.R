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
  actiread::acti_read_gt3x(
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
}

ww_read_gt3x_orig = function(
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


  data = read.gt3x::read.gt3x(
    path = path,
    asDataFrame = asDataFrame,
    imputeZeroes = imputeZeroes,
    verbose = verbose > 1,
    ...)

  if (fill_zeroes) {
    if (verbose) {
      cli::cli_alert_info("Filling zeros in data")
    }
    data = ww_fill_zeros(data)
    if (verbose) {
      cli::cli_alert_success("Filled zeros in data")
    }
  }

  # this puts data in correct timezone (still ends up in UTC)
  hdr = attr(data, "header")
  if (NROW(hdr$TimeZone) == 0 || is.null(hdr$TimeZone)) {
    cli::cli_warn("No header found in gt3x file.")
  } else {
    tz_from_offset = tzoffset_to_tz(hdr$TimeZone)
    if (verbose) {
      cli::cli_alert_info("Timezone from header: {hdr$TimeZone}")
      cli::cli_alert_info("Timezone from offset: {tz_from_offset}")
    }
  }

  any_na_time = anyNA(data$time)
  if (any_na_time) {
    warning("Some missing times in gt3x data - please check.")
  }
  if (apply_tz) {
    # data$time = lubridate::force_tz(
    #   lubridate::with_tz(data$time, tz_from_offset),
    #   "GMT")
    if (verbose) {
      cli::cli_alert_info("Timezone applied to data")
    }
    data$time = lubridate::with_tz(data$time, tz_from_offset)
    if (!is.null(tz)) {
      data$time = lubridate::force_tz(data$time, tz = tz)
    }
    if (!any_na_time && anyNA(data$time)) {
      stop("Applying timezone from offset created NA times - stopping.")
    }
  } else {
    if (verbose) {
      cli::cli_alert_info("Timezone not applied to data")
    }
  }
  data = as.data.frame(data)
  if (check_attributes) {
    stopifnot(!is.null(attr(data, "sample_rate")))
  }
  data
}


#' @inherit actiread::acti_info_gt3x
#' @export
ww_info_gt3x = actiread::acti_info_gt3x
