#' Process SensorLog Daa
#'
#' @param data A `data.frame` from [ww_read_sensorlog]
#' @param lat Latitude of central point (e.g. home) to calculate distance.
#' Set to `NULL` if distnace not to be run.
#' @param lon Longitude of central point (e.g. home) to calculate distance
#' Set to `NULL` if distnace not to be run.
#' @param dist_fun Distance function to pass to [geosphere::distm]
#' @param expected_timezone Expected Timezone based on the latitude/longitude
#' of the data based on the lat/lon values from SensorLog.  Set to
#' `NULL` if not to be checked.
#'
#' @return A `data.frame` of transformed data
#' @export
#'
#' @examples
ww_process_sensorlog = function(
    data,
    lat = NULL,
    lon = NULL,
    dist_fun = geosphere::distVincentyEllipsoid,
    expected_timezone = "America/New_York"
) {
  data = ww_check_data(data)
  if (!is.null(lat) & !is.null(lon)) {
    data = ww_calculate_distance(data,
                                 lat = lat,
                                 lon = lon,
                                 dist_fun = dist_fun)
  }
  data = ww_process_time(data, expected_timezone = expected_timezone)
  data
}

#' @rdname ww_process_sensorlog
#' @export
ww_check_data = function(data) {
  file = index = NULL
  rm(list = c("file", "index"))
  # make sure there are no duplicated times
  dupes = janitor::get_dupes(data, -file, -index)
  stopifnot(anyDuplicated(data$time) == 0)
  data
}



#' @rdname ww_process_sensorlog
#' @export
ww_calculate_distance = function(
    data,
    lat,
    lon,
    dist_fun = geosphere::distVincentyEllipsoid) {
  stopifnot(!is.null(lat), !is.null(lon))
  distance = geosphere::distm(
    as.matrix(data[, c("lon", "lat")]),
    c(lon, lat),
    fun = dist_fun
  )

  stopifnot(is.matrix(distance) && ncol(distance) == 1)
  data$distance = distance[, 1]
  data
}
