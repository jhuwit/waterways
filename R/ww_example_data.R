#' Paths to Example data
#' @description
#' Simple wrapper of [base::system.file()] to get the files included in
#' the package
#'
#' @returns A character file name
#' @rdname ww_example_data
#' @export
#'
#' @examples
#' ww_example_sensorlog_file()
#' ww_example_gt3x_file()
#' ww_example_sensorlogger_file()
ww_example_sensorlog_file = function() {
  base::system.file(
    "extdata", "SensorLogFiles_my_iOS_device_250311_14-55-58.zip",
    package = "waterways")
}

#' @rdname ww_example_data
#' @export
ww_example_gt3x_file = function() {
  base::system.file(
    "extdata", "TAS1H30182789_2025-03-11.gt3x.gz",
    package = "waterways")
}

#' @rdname ww_example_data
#' @export
ww_example_sensorlogger_file = function() {
  base::system.file(
    "extdata", "SensorLogger-2025-04-28_22-04-35.zip",
    package = "waterways")
}

#' @rdname ww_example_data
#' @export
ww_example_sensorlogger_location_file = function() {
  base::system.file(
    "extdata", "SensorLogger_Location.csv.gz",
    package = "waterways")
}
