#' Summarize SensorLog Data
#'
#' @param data `data.frame` of the data, output from `ww_process_sensorlog`
#' @param seconds integer of the number of seconds to summarize the data,
#' usually 1 minute
#'
#' @returns The `data.frame` with the summarized data, by taking the
#' mean of
#' @export
#'
#' @examples
ww_summarize_sensorlog = function(data, seconds = 60L) {

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
ww_summarise_sensorlog = ww_summarize_sensorlog
