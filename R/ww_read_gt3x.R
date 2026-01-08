ww_fill_zeros = function(x) {
  x$all_zero = x$X == 0 & x$Y == 0 & x$Z == 0
  x$X = ifelse(x$all_zero, NA_real_, x$X)
  x$Y = ifelse(x$all_zero, NA_real_, x$Y)
  x$Z = ifelse(x$all_zero, NA_real_, x$Z)
  x$all_zero = NULL

  x$X = vctrs::vec_fill_missing(x$X, direction = "down")
  x$Y = vctrs::vec_fill_missing(x$Y, direction = "down")
  x$Z = vctrs::vec_fill_missing(x$Z, direction = "down")

  x
}




#' Read GT3X file
#'
#' @param path Path to gt3x file
#' @param asDataFrame convert to an `activity_df`, see
#' \code{as.data.frame.activity}
#' @param imputeZeroes Impute zeros in case there are missingness?
#' Default is `FALSE`, in which case
#' the time series will be incomplete in case there is missingness.
#' @param ... additional arguments to pass to [read.gt3x::read.gt3x()]
#' @param verbose print diagnostic messages, higher values = more verbosity.
#' @param apply_tz Apply the timezone from the header `TimeZone` attribute
#' @param check_attributes Check that the attributes are included This is a sanity check,
#' including checking that `sample_rate` is in the attributes.
#' @param tz timezone to project the data into.  The data read in via
#' [read.gt3x::read.gt3x()] says the timezone is GMT, but the time values is in the
#' native timezone.  So this data is projected into the correct time zone and then
#' forced into the timezone given by `tz`.  Set to `NULL` to not apply this
#' forcing.
#' @param fill_zeroes Rows with all zeros will be filled in with the last
#' observation carried forward as is done with ActiLife.  Recommended
#' @returns A `data.frame`
#' @export
#'
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
