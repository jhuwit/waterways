

#' @export
#' @rdname ww_read_sensorlogger
ww_sensorlogger_location_colnames_mapping = function() {
  cn =  c(
    time = "time",
    seconds_elapsed = "seconds_elapsed",
    altitude = "altitude",
    speedAccuracy = "speed_accuracy",
    bearingAccuracy = "bearing_accuracy",
    latitude = "lat",
    altitudeAboveMeanSeaLevel = "altitude_above_mean_sea_level",
    bearing = "bearing",
    horizontalAccuracy = "horizontal_accuracy",
    verticalAccuracy = "vertical_accuracy",
    longitude = "lon",
    speed = "speed"
  )
  cn
}

#' @export
#' @rdname ww_read_sensorlogger
ww_sensorlogger_location_spec = function() {
  spec = readr::cols(
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
  spec
}


ww_convert_sensorlogger_time = function(x) {
  as_datetime_safe(x/1000/1000/1000)
}

create_lat_lon_zero = function(df) {
  lon_zero = lat_zero = lat = lon = NULL
  rm(list = c("lat", "lon", "lat_zero", "lon_zero"))

  # should add lat_zero in there
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

ww_read_sensorlogger_location = function(file) {
  df = read_csv_safe(file)
  if (nrow(df) == 0) {
    return(NULL)
  }
  cn = ww_sensorlogger_location_colnames_mapping()
  spec = ww_sensorlogger_location_spec()

  df = df[, cn]
  colnames(df) = names(cn)
  df$time = ww_convert_sensorlogger_time(df$time)
  df = create_lat_lon_zero(df)
  df$file = file
  stub = sub("[.]csv$", "", basename(file), ignore.case = TRUE)
  stub = tolower(stub)
  df$cat_type_sensor = stub
  df
}



#' Read SensorLogger Data
#'
#' @param files A character vector of SensorLogger files, usually from unzipping
#' the file
#' @param verbose print diagnostic messages.  Either logical or integer, where
#' higher values are higher levels of verbosity.
#' @return A `data.frame` of data
#' @export
ww_read_sensorlogger = function(
    files,
    verbose = FALSE
) {
  file = lon_zero = lat_zero = lat = lon = NULL
  rm(list = c("lat", "lon", "lat_zero", "lon_zero", "file"))

  files = unzip_files(files)
  stub = sub("[.]csv$", "", basename(files), ignore.case = TRUE)
  stub = tolower(stub)
  names(files) = stub

  data = ww_read_sensorlogger_location(files[["location"]])

  if (nrow(data) > 0) {
    data = data %>%
      dplyr::select(file, dplyr::everything())
  }
  data
}
