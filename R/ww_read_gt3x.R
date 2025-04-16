ww_read_gt3x = function(
    path,
    verbose = TRUE,
    asDataFrame = TRUE,
    imputeZeroes = TRUE,
    ...,
    apply_tz = TRUE
) {

  data = read.gt3x::read.gt3x(
    path = path,
    asDataFrame = asDataFrame,
    imputeZeroes = imputeZeroes,
    verbose = verbose,
    ...)

  data = ww_fill_zeros(data)

  # this puts data in correct timezone (still ends up in UTC)
  hdr = attr(data, "header")
  if (NROW(hdr$TimeZone) == 0) {
    warning("No header found in gt3x file.")
  } else {
    tz_from_offset = tzoffset_to_tz(hdr$TimeZone)
  }

  any_na_time = anyNA(data$time)
  if (any_na_time) {
    warning("Some missing times in gt3x data - please check.")
  }
  if (apply_tz) {
    data$time = lubridate::force_tz(
      lubridate::with_tz(data$time, tz_from_offset),
      "GMT")
    if (!any_na_time && anyNA(data$time)) {
      stop("Applying timezone from offset created NA times - stopping.")
    }
  }
  data = as.data.frame(data)
  stopifnot(!is.null(attr(data, "sample_rate")))
  data
}
