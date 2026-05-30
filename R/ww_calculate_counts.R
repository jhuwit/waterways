#' @inherit actimetrics::acti_calculate_counts
#' @name ww_calculate_counts
#' @export
#' @examples
#' path = ww_example_gt3x_file()
#' ac = ww_read_gt3x(path, verbose = FALSE)
#' out = ww_calculate_counts(ac)
ww_calculate_counts = actimetrics::acti_calculate_counts


#' @inherit actimetrics::acti_calculate_wear
#' @name ww_calculate_wear
#' @export
ww_calculate_wear = actimetrics::acti_calculate_wear

#' @export
#' @rdname ww_calculate_wear
ww_calculate_nonwear = ww_calculate_wear

#' @inherit actimetrics::acti_process
#' @name ww_process_gt3x
#' @export
ww_process_gt3x = actimetrics::acti_process


rename_timestamp = function(data) {
  timestamp = time = NULL
  rm(list = c("timestamp", "time"))
  if ("time" %in% colnames(data) && !"timestamp" %in% colnames(data)) {
    data = data %>% dplyr::rename(timestamp = time)
  }
  data
}

#' @inherit actimetrics::acti_apply_cole_kripke
#' @name ww_apply_cole_kripke
#' @export
ww_apply_cole_kripke = actimetrics::acti_apply_cole_kripke


#' @inherit actimetrics::acti_apply_tudor_locke
#' @name ww_apply_tudor_locke
#' @export
ww_apply_tudor_locke = actimetrics::acti_apply_tudor_locke


#' @param data_bed_times A `data.frame` containing bed times with columns
#' `in_bed_time`, `out_bed_time`, and `onset` or `onset_time`.  If `NULL`,
#' [ww_apply_tudor_locke] is used to estimate sleep metrics.
#' @export
#' @rdname ww_apply_tudor_locke
ww_estimate_sleep = function(
    data,
    data_bed_times = NULL,
    verbose = TRUE
) {
  in_bed = index = onset = timestamp = time = NULL
  rm(list = c("index", "onset", "timestamp", "time", "in_bed"))
  if (!"sleep" %in% colnames(data)) {
    if (verbose) {
      cli::cli_alert_info("Running ww_apply_cole_kripke to add sleep column")
    }
    data = data %>%
      ww_apply_cole_kripke()
  }

  if (is.null(data_bed_times)) {
    if (verbose) {
      cli::cli_alert_info("Running ww_apply_tudor_locke to estimate sleep")
    }
    metrics = data %>%
      ww_apply_tudor_locke()
  } else {
    required_cn = c("in_bed_time", "out_bed_time", "onset")
    assertthat::assert_that(
      assertthat::has_name(data_bed_times, "in_bed_time"),
      assertthat::has_name(data_bed_times, "out_bed_time"),
      assertthat::has_name(data_bed_times, "onset") |  assertthat::has_name(data_bed_times, "onset_time")
    )
    if (!assertthat::has_name(data_bed_times, "onset_time") &
        assertthat::has_name(data_bed_times, "onset")) {
      data_bed_times = data_bed_times %>%
        dplyr::rename(onset_time = onset)
    }


    data_bed_times = data_bed_times %>%
      dplyr::ungroup() %>%
      dplyr::mutate(index = dplyr::row_number())

    data = apply_diary_bed_times(data, data_bed_times, check_times = TRUE)

    # split by the night/sleeping event
    data_split = data %>%
      dplyr::filter(in_bed) %>%
      dplyr::group_split(index)
    # purrr::map(data_sleep_split, function(x) range(x$time))
    # diary_i %>% select(in_bed_time, onset_time, out_bed_time)

    # Calculate sleep metrics for each sleeping event
    metrics = purrr::map_df(data_split, function(data_i) {
      stopifnot(all(data_i$in_bed))
      calculate_sleep_metrics(data_i, rounder = "Round")
    }, .id = "index") %>%
      dplyr::mutate(index = as.numeric(index))

    # Rename columns to match Diary output
    # metrics = metrics %>%
    #   dplyr::select(Latency = latency,
    #          `Total Counts` = total_counts,
    #          Efficiency = efficiency,
    #          `Total Minutes in Bed` = total_minutes_in_bed,
    #          `Total Sleep Time (TST)` = total_sleep_time,
    #          `Wake After Sleep Onset (WASO)` = waso,
    #          `Movement Index` = movement_index,
    #          `Fragmentation Index` = fragmentation_index,
    #          `Sleep Fragmentation Index` = sleep_fragmentation_index,
    #          `Number of Awakenings` = nb_awakenings,
    #          `Average Awakening Length` = avg_awakening_length,
    #          everything()) %>%
    #   mutate(ID = id)
    metrics = data_bed_times %>%
      dplyr::right_join(metrics, by = "index") %>%
      dplyr::select(-index)

  }


  metrics

}
