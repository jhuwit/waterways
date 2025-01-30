# zip_file = "data/SensorLog/OCEANS_011_BL/SensorLogFiles_OCEANS_011_BL_221208_11-55-16.zip"


#' Read SensorLog Data
#'
#' @param files A character vector of SensorLog files, usually from unzipping
#' the file
#'
#' @return A `data.frame` of data
#' @export
ww_read_sensorlog = function(
    files
) {
  lat = lon = NULL
  rm(list = c("lat", "lon"))

  names(files) = files

  cn = ww_csv_colnames_mapping()
  spec = ww_csv_spec()

  files = sapply(files, rewrite_csv, verbose = FALSE)
  data =
    purrr::map_df(files, function(x) {
      r = read_csv_safe(x, progress = FALSE, col_types = spec)
      # r = readr::read_csv(x, col_types = spec)
      if (nrow(r) == 0) {
        return(NULL)
      }
      make_na_cols = c("locationSpeedAccuracy(m/s)")
      missing_cols = setdiff(cn, colnames(r))
      if (length(missing_cols) > 0) {
        print(paste(missing_cols), collapse = ", ")
        for (icol in intersect(missing_cols, make_na_cols)) {
          r[[icol]] = NA_real_
        }
      }
      r = r[, cn]
      colnames(r) = names(cn)

      r = r %>%
        dplyr::mutate(
          lat = ifelse(abs(lat) < 0.00001, NA_real_, lat),
          lon = ifelse(abs(lon) < 0.00001, NA_real_, lon)
        )

      r
    }, .id = "file")


  data
}






#' @export
#' @rdname ww_read_sensorlog
ww_csv_spec = function() {
  spec = readr::cols(
    `loggingTime(txt)` = readr::col_character(),
    `loggingSample(N)` = readr::col_double(),
    `locationTimestamp_since1970(s)` = readr::col_double(),
    `locationLatitude(WGS84)` = readr::col_double(),
    `locationLongitude(WGS84)` = readr::col_double(),
    `locationAltitude(m)` = readr::col_double(),
    `locationSpeed(m/s)` = readr::col_double(),
    `locationSpeedAccuracy(m/s)` = readr::col_double(),
    `accelerometerAccelerationX(G)` = readr::col_double(),
    `accelerometerAccelerationY(G)` = readr::col_double(),
    `accelerometerAccelerationZ(G)` = readr::col_double(),
    .default = readr::col_character()
  )
  spec
}

#' @export
#' @rdname ww_read_sensorlog
ww_csv_colnames_mapping = function() {
  cn =  c(
    time = "loggingTime(txt)",
    index = "loggingSample(N)",
    timestamp = "locationTimestamp_since1970(s)",
    lat = "locationLatitude(WGS84)",
    lon = "locationLongitude(WGS84)",
    altitude = "locationAltitude(m)",
    speed = "locationSpeed(m/s)",
    speed_accuracy = "locationSpeedAccuracy(m/s)",
    accel_X = "accelerometerAccelerationX(G)",
    accel_Y = "accelerometerAccelerationY(G)",
    accel_Z = "accelerometerAccelerationZ(G)")
  cn
}
