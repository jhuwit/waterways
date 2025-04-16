
#' Process the Time data from SensorLog and Compare to an Expected Timezone
#'
#' @inheritParams ww_process_sensorlog
#' @param ... additional arguments to pass to [lutz::tz_lookup_coords()]
#'
#' @return A `data.frame`
#' @param tz timezone to project the data into.  Keeping as `GMT` to agree
#' with ActiGraph, passed to [lubridate::as_datetime].
#' @param check_data if `TRUE` any duplicates for time are checked for.
#' @export
ww_process_time = function(data,
                           expected_timezone = "America/New_York",
                           tz = "GMT",
                           check_data = TRUE,
                           verbose = FALSE,
                           ...) {

  time = timestamp = NULL
  rm(list = c("time", "timestamp"))

  data$timezone_estimated = lutz::tz_lookup_coords(
    lat = data$lat,
    lon = data$lon,
    warn = verbose,
    ...
  )
  if (!is.null(expected_timezone)) {
    uest = sort(table(data$timezone_estimated), decreasing = TRUE)
    uest = names(uest[1])
    stopifnot(uest == expected_timezone)
  }

  data = data %>%
    dplyr::mutate(
      char_time = as.character(time)
    )

  data = data %>%
    dplyr::mutate(
      time = strip_hour_shift(time)
    )

  data = data %>%
    dplyr::mutate(
      # use GMT to agree with ActiGraph
      time = as_datetime_safe(time, tz = tz),
      timestamp = as_datetime_safe(timestamp)
    )
  if (check_data) {
    stopifnot(anyDuplicated(data$time) == 0)
    stopifnot(anyDuplicated(data$timestamp) == 0)
  }
  data
}
