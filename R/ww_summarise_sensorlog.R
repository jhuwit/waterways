#' @inherit actisensorlog::acti_summarize_sensorlog
#' @export
ww_summarize_sensorlog = actisensorlog::acti_summarize_sensorlog

#' @rdname ww_summarize_sensorlog
#' @export
ww_summarise_sensorlog = ww_summarize_sensorlog



#' @rdname ww_summarize_sensorlog
#' @param seconds integer of the number of seconds to summarize the data
#' for the "minute" level. Usually 1 minute/60 seconds.  For
#' `ww_summarize_distance_sensorlog`, summarization is done depending on how the
#' data is grouped.
#' @export
ww_minute_sensorlog = actisensorlog::acti_minute_sensorlog

#' @rdname ww_summarize_sensorlog
#' @export
ww_summarize_distance_sensorlog = actisensorlog::acti_summarize_distance_sensorlog
