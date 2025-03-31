#' Separate Times into Date, Hour, and Minute
#'
#' @param data a `data.frame` with a `time` column
#'
#' @returns A `data.frame` with date, hour, minute, and day columns
#' @export
#'
#' @examples
#' df = data.frame(
#'   time = seq(Sys.time(), Sys.time() + 1000, by = 1)
#' )
#' ww_separate_times(df)
ww_separate_times = function(data) {
  minute = hour = day = date = NULL
  rm(list = c("minute", "day", "hour", "date"))
  data = data %>%
    dplyr::mutate(
      date = lubridate::floor_date(time, "1 day"),
      date = lubridate::as_date(date),
      hour = lubridate::floor_date(time, "1 hour"),
      hour = hms::as_hms(hour),
      minute = lubridate::floor_date(time, "1 minute"),
      minute = hms::as_hms(minute)
    )
  data = data %>%
    dplyr::mutate(
      day = as.numeric(difftime(date, min(date), units = "days") + 1)
    )
  data
}
