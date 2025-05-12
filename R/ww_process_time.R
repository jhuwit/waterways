
#' Process the Time data from SensorLog and Compare to an Expected Timezone
#'
#' @inheritParams ww_process_sensorlog
#' @param ... additional arguments to pass to [lutz::tz_lookup_coords()]
#' @param apply_tz Apply the timezone from the timezone shift from the timezone,
#' e.g. "2025-03-11T14:44:11-04:00" becomes "2025-03-11T18:44:11" if
#' `apply_tz = TRUE`, but "2025-03-11T14:44:11" if `apply_tz = FALSE`.
#' @return A `data.frame`
#' @param tz timezone to project the data into.  Keeping as `GMT` and should
#' have same value for `apply_tz` to agree (caution: always check data)
#' with ActiGraph, passed to [lubridate::as_datetime].
#' @param check_data if `TRUE` any duplicates for time are checked for.
#' @export
ww_process_time = function(data,
                           expected_timezone = "America/New_York",
                           tz = "GMT",
                           apply_tz = TRUE,
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
      time = strip_hour_shift(time, max_index = 2L)
    )
  if (!apply_tz) {
    data = data %>%
      dplyr::mutate(
        time = sub("\\s([+]|-).*", "", time)
      )
  }

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
