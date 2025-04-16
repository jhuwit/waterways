#' Process SensorLog Daa
#'
#' @param data A `data.frame` from [ww_read_sensorlog]
#' @param lat Latitude of central point (e.g. home) to calculate distance.
#' Set to `NULL` if distnace not to be run.
#' @param lon Longitude of central point (e.g. home) to calculate distance
#' Set to `NULL` if distnace not to be run.
#' @param dist_fun Distance function to pass to [geosphere::distm]
#' @param expected_timezone Expected Timezone based on the latitude/longitude
#' of the data based on the lat/lon values from SensorLog (
#' e.g. `"America/New_York"`).  Set to
#' `NULL` if not to be checked.
#' @param check_data should [ww_check_data] be run?
#' @param remove_cols columns to remove from duplicate checking in
#' [ww_check_data].  Default is `c("file", "index")`
#'
#' @return A `data.frame` of transformed data
#' @note This calls [ww_check_data], [ww_calculate_distance], and
#' [ww_process_time]
#' @param verbose print diagnostic messages.  Either logical or integer, where
#' higher values are higher levels of verbosity.
#' @param ... additional arguments to pass to [ww_process_time]
#' @export
#'
ww_process_sensorlog = function(
    data,
    lat = NULL,
    lon = NULL,
    dist_fun = geosphere::distVincentyEllipsoid,
    expected_timezone = NULL,
    check_data = TRUE,
    remove_cols = c("file", "index"),
    verbose = FALSE,
    ...,
    distance_cutoff = 180
) {
  if (check_data) {
    data = ww_check_data(data, remove_cols = remove_cols)
  }
  if (!is.null(lat) & !is.null(lon)) {
    data = ww_calculate_distance(data,
                                 lat = lat,
                                 lon = lon,
                                 dist_fun = dist_fun,
                                 distance_cutoff = distance_cutoff)
  } else {
    data = data %>%
      dplyr::mutate(distance = NA_real_,
                    is_within_home = NA)
  }
  data = data %>%
    # define within home as 180 meters or whatever cutoff
    dplyr::mutate(
      # calculate distance traveled
      distance_traveled = c(NA_real_, dist_fun(cbind(lon, lat))),
    )
  data = ww_process_time(data,
                         expected_timezone = expected_timezone,
                         check_data = check_data,
                         verbose = verbose > 0,
                         ...)
  data
}

#' @rdname ww_process_sensorlog
#' @export
ww_check_data = function(data,
                         remove_cols = c("file", "index")) {
  file = index = NULL
  rm(list = c("file", "index"))
  # make sure there are no duplicated times
  dupes = janitor::get_dupes(data, -dplyr::any_of(remove_cols))
  stopifnot(anyDuplicated(data$time) == 0)
  data
}



#' @rdname ww_process_sensorlog
#' @param distance_cutoff Distance in meters to consider within home,
#' in meters
#' @export
ww_calculate_distance = function(
    data,
    lat,
    lon,
    distance_cutoff = 180,
    dist_fun = geosphere::distVincentyEllipsoid) {
  stopifnot(!is.null(lat), !is.null(lon))
  distance = geosphere::distm(
    as.matrix(data[, c("lon", "lat")]),
    c(lon, lat),
    fun = dist_fun
  )

  stopifnot(is.matrix(distance) && ncol(distance) == 1)
  data$distance = distance[, 1]

  assertthat::assert_that(
    is.numeric(distance_cutoff)
  )
  # just being overly cautious in case lat/lon passed in
  # gets confused in mutate
  lat = long = NULL
  rm(list = c("lat", "lon"))
  data = data %>%
    # define within home as 180 meters or whatever cutoff
    dplyr::mutate(
      is_within_home = distance <= distance_cutoff
    )
  data
}
