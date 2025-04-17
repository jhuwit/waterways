#' Process SensorLog Daa
#'
#' @param data A `data.frame` from [ww_read_gt3x]
#' @return A `data.frame` of transformed data
#' @note This calls [ww_check_data], [ww_calculate_distance], and
#' [ww_process_time]
#' @param verbose print diagnostic messages.  Either logical or integer, where
#' higher values are higher levels of verbosity.
#' @param ... additional arguments to pass to [ww_process_time]
#' @export
#' @examples
#' path = ww_example_gt3x_file()
#' ac = ww_read_gt3x(path, verbose = FALSE)
#' out = ww_calculate_counts(ac)
ww_calculate_counts = function(
    data,
    epoch = 60L,
    lfe_select = FALSE,
    verbose = TRUE
) {
  vector.magnitude = NULL
  rm(list = c("vector.magnitude"))
  stopifnot(!is.null(attr(data, "sample_rate")))
  tz = lubridate::tz(data$time)
  counts = agcounts::calculate_counts(
    raw = data,
    epoch = epoch,
    tz = tz,
    lfe_select = lfe_select,
    verbose = verbose
  )
  counts = counts %>%
    dplyr::rename_with(tolower)
  counts = counts %>%
    dplyr::rename(counts = vector.magnitude)
  counts = counts %>% dplyr::as_tibble()
}

#' @param method Method for detecting non-wear, either "choi" or "troiano",
#' corresponding to [actigraph.sleepr::apply_choi] or [actigraph.sleepr::apply_troiano]
#' @param ... additional arguments to pass to `actigraph.sleepr` function
#' @export
#' @rdname ww_calculate_counts
ww_calculate_nonwear = function(data, method = c("choi", "troiano"),
                                ...) {
  data = data %>%
    dplyr::rename(timestamp = time)
  mode(data$timestamp) = "double"
  method = match.arg(method)
  func = switch(method,
                choi = function(x, ...) actigraph.sleepr::apply_choi(x, ...),
                troiano = function(x, ...) actigraph.sleepr::apply_troiano(x, ...)
                )
  choi_nonwear = func(data)
  if (nrow(choi_nonwear) > 0) {
    choi_df = purrr::map2_df(
      choi_nonwear$period_start, choi_nonwear$period_end,
      function(from, to) {
        data.frame(timestamp = seq(from, to, by = 60L),
                   wear = FALSE)
      })
    choi_df = dplyr::left_join(data, choi_df) %>%
      tidyr::replace_na(list(wear = TRUE))
  } else {
    choi_df = data.frame(timestamp = unique(data$timestamp),
                         wear = TRUE)
  }


  choi_df = choi_df %>%
    dplyr::rename(time = timestamp) %>%
    dplyr::select(time, dplyr::contains("wear")) %>%
    dplyr::as_tibble()
}
