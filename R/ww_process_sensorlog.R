#' @inherit actisensorlog::acti_process_sensorlog
#' @export
#' @examples
#' file = ww_example_sensorlog_file()
#' df = ww_read_sensorlog(file)
#' head(df)
#' result = ww_process_sensorlog(df, check_data = FALSE, tz = "GMT")
#' out = ww_minute_sensorlog(result)
#' out = ww_summarize_sensorlog(result)
#'
ww_process_sensorlog = actisensorlog::acti_process_sensorlog

#' @rdname ww_process_sensorlog
#' @export
ww_check_data = actisensorlog::acti_check_duplicate_times



#' @rdname ww_process_sensorlog
#' @param distance_cutoff Distance in meters to consider within home,
#' in meters
#' @export
ww_calculate_distance = actisensorlog::acti_calculate_distance
