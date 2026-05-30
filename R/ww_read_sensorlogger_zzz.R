#' Read SensorLogger Data
#'
#' @param file A character vector of SensorLogger files, usually from unzipping
#' the file, or a zip file of SensorLogger files
#' @param verbose print diagnostic messages.  Either logical or integer, where
#' higher values are higher levels of verbosity.
#' @param ... additional arguments to pass to [readr::read_csv()].
#' If `verbose = FALSE`, then `progress = FALSE` and `show_col_types = FALSE`,
#' unless otherwise overridden
#' @return A `data.frame` of data
#' @export
ww_read_sensorlogger = function(
    file,
    verbose = FALSE,
    ...
) {
  file = ww_unzip_sensorlogger_files(file)
  stub = ww_sensorlogger_stub(file)
  names(file) = stub

  data_list = purrr::map(file, function(r) {
    ww_read_sensorlogger_by_type(r, verbose = verbose, ...)
  })
  if (length(file) == 1 && length(data_list) == 1) {
    data_list = data_list[[1]]
  }

  data_list
}

ww_unzip_sensorlogger_files = function(file) {
  if (any(ww_is_zip_file(file))) {
    if (!all(ww_is_zip_file(file))) {
      stop(paste0(
        "ww_read_sensorlogger works with only zip file or a vector of ",
        "csv files"
      ))
    }
    file = lapply(file, function(r) {
      tfile = tempfile()
      utils::unzip(r, exdir = tfile)
    })
    file = unlist(file)
  }
  file
}

ww_is_zip_file = function(x) {
  grepl("[.]zip$", x, ignore.case = TRUE)
}

ww_sensorlogger_stub = function(x) {
  stub = sub("[.]csv($|[.]gz$)", "", basename(x), ignore.case = TRUE)
  stub = tolower(stub)
  stub = sub("^sensorlogger_", "", stub)
  stub = sub("uncalibrated", "_uncalibrated", stub)
  stub
}

ww_convert_sensorlogger_time = function(x) {
  as_datetime_safe(x / 1000 / 1000 / 1000)
}

ww_read_sensorlogger_by_type = function(file, ..., type = NULL, verbose = FALSE) {
  if (is.null(type)) {
    type = ww_sensorlogger_stub(file)
  }
  func = switch(
    type,
    accelerometer = ww_read_sensorlogger_general,
    accelerometer_uncalibrated = ww_read_sensorlogger_general,
    annotation = ww_read_sensorlogger_general,
    battery = ww_read_sensorlogger_general,
    gravity = ww_read_sensorlogger_general,
    gyroscope = ww_read_sensorlogger_general,
    gyroscope_uncalibrated = ww_read_sensorlogger_general,
    location = ww_read_sensorlogger_location,
    metadata = ww_read_sensorlogger_general,
    orientation = ww_read_sensorlogger_general,
    pedometer = ww_read_sensorlogger_general,
    ww_read_sensorlogger_general
  )
  args = list(...)
  if (!verbose && !"progress" %in% names(args)) {
    args$progress = FALSE
  }
  if (!verbose && !"show_col_types" %in% names(args)) {
    args$show_col_types = FALSE
  }
  args$file = file
  do.call(func, args = args)
}
