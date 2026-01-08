#' Process SensorLog Daa
#'
#' @param data A `data.frame` from [ww_read_gt3x]
#' @return A `data.frame` of transformed data
#' @note This calls [ww_check_data], [ww_calculate_distance], and
#' [ww_process_time]
#' @param verbose print diagnostic messages.  Either logical or integer, where
#' @param epoch epoch length in seconds.  Default is 60 seconds.
#' See [agcounts::calculate_counts]
#' @param lfe_select Apply the Actigraph Low Frequency Extension filter.
#' See [agcounts::calculate_counts]
#' higher values are higher levels of verbosity.
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
#' @param use_magnitude  If `TRUE`, the magnitude of the vector
#' (axis1, axis2, axis3) is used to measure activity;
#' otherwise the axis1 value is used.
#' @export
#' @rdname ww_calculate_counts
ww_calculate_wear = function(data,
                             method = c("choi", "troiano"),
                             use_magnitude = TRUE,
                             ...) {
  time = timestamp = NULL
  rm(list = c("time", "timestamp"))
  data = data %>%
    dplyr::rename(timestamp = time)
  mode(data$timestamp) = "double"
  method = match.arg(method)
  func = switch(method,
                choi = function(x, ...) actigraph.sleepr::apply_choi(
                  x,
                  use_magnitude = use_magnitude,
                  ...),
                troiano = function(x, ...) actigraph.sleepr::apply_troiano(
                  x,
                  use_magnitude = use_magnitude,
                  ...)
  )
  choi_nonwear = func(data)
  if (nrow(choi_nonwear) > 0) {
    choi_df = purrr::map2_df(
      # change for the end - not the last value
      choi_nonwear$period_start, choi_nonwear$period_end - 60L,
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

#' @export
#' @rdname ww_calculate_counts
ww_calculate_nonwear = ww_calculate_wear

#' @export
#' @rdname ww_calculate_counts
#' @note For `ww_process_gt3x`, the `...` argument are passed to
#' [ww_read_gt3x]
ww_process_gt3x = function(data,
                           lfe_select = FALSE,
                           method = c("choi", "troiano"),
                           use_magnitude = TRUE,
                           verbose = TRUE,
                           ...) {
  if (assertthat::is.string(data) &&
      file.exists(data)) {
    data = ww_read_gt3x(data, ...,
                        verbose = verbose)
  }

  counts = ww_calculate_counts(
    data,
    lfe_select = lfe_select,
    verbose = verbose)

  # Process the data
  wear = ww_calculate_nonwear(
    counts,
    method = method,
    use_magnitude = use_magnitude)

  result = dplyr::full_join(counts, wear, by = "time") %>%
    dplyr::mutate(wear = ifelse(is.na(wear), FALSE, wear))

  return(result)
}

rename_timestamp = function(data) {
  timestamp = time = NULL
  rm(list = c("timestamp", "time"))
  if ("time" %in% colnames(data) && !"timestamp" %in% colnames(data)) {
    data = data %>% dplyr::rename(timestamp = time)
  }
  data
}

#' @export
#' @rdname ww_calculate_counts
ww_apply_cole_kripke = function(data) {
  timestamp = NULL
  rm(list = c("timestamp"))
  data = data %>% rename_timestamp()

  # https://actigraphcorp.my.site.com/support/s/article/What-does-the-Detect-Sleep-Periods-button-do-and-how-does-it-work
  ck = data %>%
    actigraph.sleepr::apply_cole_kripke()
  ck = ck %>%
    dplyr::rename(time = timestamp)
  ck
}

#' @export
#' @rdname ww_calculate_counts
ww_apply_tudor_locke = function(data, ...) {
  data = data %>% rename_timestamp()
  tl = data %>%
    actigraph.sleepr::apply_tudor_locke(...)
  tl
}

#' @param data_bed_times A `data.frame` containing bed times with columns
#' `in_bed_time`, `out_bed_time`, and `onset` or `onset_time`.  If `NULL`,
#' [ww_apply_tudor_locke] is used to estimate sleep metrics.
#' @export
#' @rdname ww_calculate_counts
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
