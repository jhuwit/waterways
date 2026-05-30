#' @inherit actiread::acti_sensorlogger_location_colnames_mapping
#' @rdname ww_sensorlogger
#' @export
ww_sensorlogger_location_colnames_mapping = function() {
  c(
    time = "time",
    seconds_elapsed = "seconds_elapsed",
    altitude = "altitude",
    speed_accuracy = "speedAccuracy",
    bearing_accuracy = "bearingAccuracy",
    lat = "latitude",
    altitude_above_mean_sea_level = "altitudeAboveMeanSeaLevel",
    bearing = "bearing",
    horizontal_accuracy = "horizontalAccuracy",
    vertical_accuracy = "verticalAccuracy",
    lon = "longitude",
    speed = "speed"
  )
}

#' @rdname ww_sensorlogger
#' @export
ww_sensorlogger_location_spec = function() {
  readr::cols(
    time = readr::col_double(),
    seconds_elapsed = readr::col_double(),
    altitude = readr::col_double(),
    speedAccuracy = readr::col_double(),
    bearingAccuracy = readr::col_double(),
    latitude = readr::col_double(),
    altitudeAboveMeanSeaLevel = readr::col_double(),
    bearing = readr::col_double(),
    horizontalAccuracy = readr::col_double(),
    verticalAccuracy = readr::col_double(),
    longitude = readr::col_double(),
    speed = readr::col_double()
  )
}

ww_create_lat_lon_zero = function(df) {
  lon_zero = lat_zero = lat = lon = NULL
  rm(list = c("lat", "lon", "lat_zero", "lon_zero"))

  df = df %>%
    dplyr::mutate(
      lat_zero = abs(lat) < 0.00001,
      lon_zero = abs(lon) < 0.00001
    )
  df = df %>%
    dplyr::mutate(
      lat = ifelse(lat_zero, NA_real_, lat),
      lon = ifelse(lon_zero, NA_real_, lon)
    )
  df
}

#' @rdname ww_sensorlogger
#' @export
ww_read_sensorlogger_location = function(file, ...) {
  args = list(...)
  if (!"col_types" %in% names(args)) {
    args$col_types = ww_sensorlogger_location_spec()
  }
  args$file = file
  df = do.call(read_csv_safe, args)
  if (nrow(df) == 0) {
    return(NULL)
  }
  cn = ww_sensorlogger_location_colnames_mapping()

  df = df[, cn]
  colnames(df) = names(cn)
  df$time = ww_convert_sensorlogger_time(df$time)
  df = ww_create_lat_lon_zero(df)
  df$file = file
  df$cat_type_sensor = ww_sensorlogger_stub(file)
  df
}
