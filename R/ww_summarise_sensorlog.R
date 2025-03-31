#' Summarize SensorLog Data
#'
#' @param data `data.frame` of the data, output from `ww_process_sensorlog`
#'
#' @returns The `data.frame` with the summarized data, by taking the
#' mean of
#' @import rlang
#' @export
ww_summarize_sensorlog = function(data) {
  if (!assertthat::has_name(data, "time")) {
    stop("data must have a time column")
  }

  data = ww_minute_sensorlog(data, seconds = 60L)
  if (!assertthat::has_name(data, "date")) {
    data = ww_separate_times(data)
  }
  data = data %>%
    dplyr::group_by(date) %>%
    ww_summarize_distance_sensorlog() %>%
    dplyr::ungroup()

  data
}

#' @rdname ww_summarize_sensorlog
#' @export
ww_summarise_sensorlog = ww_summarize_sensorlog



#' @rdname ww_summarize_sensorlog
#' @param seconds integer of the number of seconds to summarize the data
#' for the "minute" level. Usually 1 minute/60 seconds.  For
#' `ww_summarize_distance_sensorlog`, summarization is done depending on how the
#' data is grouped.
#' @export
ww_minute_sensorlog = function(data, seconds = 60L) {
  enmo = vm = accel_X = accel_Y = accel_Z = lat = lon = NULL
  rm(list = c("lat", "lon", "accel_X", "accel_Y", "accel_Z", "vm", "enmo"))
  assertthat::assert_that(
    is.numeric(seconds)
  )
  unit = paste0(seconds, " second")

  if (!assertthat::has_name(data, "lat_zero")) {
    data = data %>%
      dplyr::mutate(
        lat_zero = abs(lat) < 0.00001 | is.na(lat),
      )
  }
  if (!assertthat::has_name(data, "lon_zero")) {
    data = data %>%
      dplyr::mutate(
        lon_zero = abs(lon) < 0.00001 | is.na(lon),
      )
  }
  for (icol in c("accel_X", "accel_Y", "accel_Z")) {
    if (!assertthat::has_name(data, icol)) {
      data = data %>%
        dplyr::mutate(
          !!icol := NA_real_
        )
    }
  }

  # summarising the data at a level
  data = data %>%
    dplyr::mutate(
      time = lubridate::floor_date(time, unit = unit),
      vm = sqrt(accel_X^2 + accel_Y^2 + accel_Z^2),
      enmo = pmax(0, vm - 1)
    ) %>%
    dplyr::group_by(time) %>%
    dplyr::summarise(
      max_speed = max(speed, na.rm = TRUE),
      dplyr::across(
        dplyr::any_of(c("lat", "lon", "speed", "accel_X",
                        "accel_Y", "accel_Z", "distance")),
        mean),
      is_within_home = all(is_within_home, na.rm = TRUE),
      distance_traveled = sum(distance_traveled),
      vm = mean(vm),
      enmo = mean(enmo),
      lat_zero = all(lat_zero),
      lon_zero = all(lon_zero)
    )
  data = data %>%
    dplyr::mutate(in_sensorlog = TRUE)

  # join all the times - now it should be full
  full_time_df = seq(min(data$time), max(data$time), by = seconds)
  full_time_df = dplyr::tibble(
    time = full_time_df
  )
  data = dplyr::full_join(
    data,
    full_time_df,
    by = dplyr::join_by(time)) %>%
    dplyr::arrange(time)
  data = data %>%
    tidyr::replace_na(list(in_sensorlog = FALSE))
  data
}

#' @rdname ww_summarize_sensorlog
#' @export
ww_summarize_distance_sensorlog = function(data) {
  n_distance_traveled = distance = sum_distance_traveled = NULL
  distance_traveled = mean_distance_traveled = max_distance = NULL
  rm(list = c("n_distance_traveled", "distance",
              "sum_distance_traveled",
              "mean_distance_traveled", "max_distance",
              "distance_traveled")
  )
  daily = data %>%
    dplyr::summarise(
      n_minutes_with_distance = sum(!is.na(distance)),
      sum_distance = sum(distance, na.rm = TRUE),
      max_distance = max(distance, na.rm = TRUE),

      sum_distance_traveled = sum(distance_traveled, na.rm = TRUE),
      mean_distance_traveled = mean(distance_traveled, na.rm = TRUE),
      n_distance_traveled = sum(!is.na(distance_traveled)),

      time_within_home = sum(is_within_home, na.rm = TRUE),
      time_outside_home = sum(!is_within_home, na.rm = TRUE),
      time_missing_home = sum(is.na(is_within_home), na.rm = TRUE)
    ) %>%
    dplyr::ungroup()
  daily = daily %>%
    dplyr::mutate(
      sum_distance_traveled = dplyr::if_else(
        n_distance_traveled == 0,
        NA_real_, sum_distance_traveled),
      mean_distance_traveled = dplyr::if_else(
        n_distance_traveled == 0,
        NA_real_, mean_distance_traveled),

      max_distance = dplyr::if_else(is.infinite(max_distance), NA_real_, max_distance)
    )
  daily
}
