with_namespace_mock = function(package, name, value, code) {
  ns = asNamespace(package)
  old = get(name, envir = ns, inherits = FALSE)
  unlockBinding(name, ns)
  assign(name, value, envir = ns)
  lockBinding(name, ns)
  on.exit({
    unlockBinding(name, ns)
    assign(name, old, envir = ns)
    lockBinding(name, ns)
  }, add = TRUE)
  force(code)
}

with_function_env_binding = function(fun, name, value, code) {
  old_env = environment(fun)
  new_env = new.env(parent = old_env)
  assign(name, value, envir = new_env)
  environment(fun) = new_env
  on.exit({
    environment(fun) = old_env
  }, add = TRUE)
  force(code)
}

test_that("utility helpers are covered", {
  testthat::expect_equal(
    waterways:::Round(c(-1.234, 1.234, 1.235), 2),
    c(-1.23, 1.23, 1.24)
  )

  testthat::expect_equal(
    waterways:::strip_hour_shift("2025-03-11 18:44:00 +04:00", max_index = 2L),
    "2025-03-11 18:44:00"
  )
  testthat::expect_equal(
    waterways:::strip_hour_shift("2025-03-11 18:44:00 -04:00", max_index = 2L),
    "2025-03-11 18:44:00"
  )

  clean_csv = tempfile(fileext = ".csv")
  writeLines("x,y\n1,2\n3,4", clean_csv)
  clean = waterways:::read_csv_safe(clean_csv, col_types = readr::cols(x = readr::col_double(), y = readr::col_double()))
  testthat::expect_equal(nrow(clean), 2L)

  bad_csv = tempfile(fileext = ".csv")
  writeLines("x\n1\nbad", bad_csv)
  testthat::expect_error(
    waterways:::read_csv_safe(
      bad_csv,
      col_types = readr::cols(x = readr::col_double())
    ),
    "parsing"
  )

  testthat::expect_equal(
    waterways:::as_date_safe(as.Date("2025-03-11")),
    as.Date("2025-03-11")
  )
  testthat::expect_equal(
    waterways:::as_datetime_safe(as.POSIXct("2025-03-11 12:34:56", tz = "UTC")),
    lubridate::as_datetime(as.POSIXct("2025-03-11 12:34:56", tz = "UTC"))
  )
  testthat::expect_error(
    waterways:::as_convert_safe("bad", func = function(x, ...) rep(as.Date(NA), length(x))),
    "conversion failed"
  )

  testthat::expect_equal(waterways:::tzoffset_to_tz(c("+04:00:00")), "Etc/GMT+4")
  testthat::expect_equal(waterways:::tzoffset_to_tz(c("-04:00:00")), "Etc/GMT-4")
})

test_that("sleep helpers are covered", {
  time0 = as.POSIXct("2025-03-11 00:00:00", tz = "GMT")
  diary = data.frame(
    in_bed_time = time0,
    out_bed_time = time0 + 6 * 60,
    onset_time = time0 + 2 * 60,
    index = 1L,
    stringsAsFactors = FALSE
  )

  expanded = waterways:::expand_start_stop(diary)
  testthat::expect_true(all(c("time", "in_bed", "is_past_onset", "index") %in% names(expanded)))
  testthat::expect_equal(nrow(expanded), 6L)

  testthat::expect_equal(
    waterways:::check_diary(dplyr::select(diary, -onset_time))$onset_time,
    diary$out_bed_time
  )
  testthat::expect_equal(
    waterways:::check_diary(dplyr::select(diary, -out_bed_time))$out_bed_time,
    diary$onset_time
  )

  data = data.frame(
    time = time0 + 0:5 * 60,
    counts = c(0, 1, 2, 0, 2, 3),
    axis1 = c(0, 1, 2, 0, 2, 3),
    sleep = c("W", "W", "S", "S", "W", "S"),
    stringsAsFactors = FALSE
  )
  data = waterways:::apply_diary_bed_times(data, diary, check_times = TRUE)
  testthat::expect_true(all(c("in_bed", "is_past_onset") %in% names(data)))

  data_manual = data.frame(
    counts = c(0, 1, 2, 0, 2, 3),
    axis1 = c(0, 1, 2, 0, 2, 3),
    sleep = c("W", "W", "S", "S", "W", "S"),
    in_bed = c(TRUE, TRUE, TRUE, TRUE, TRUE, TRUE),
    is_past_onset = c(FALSE, FALSE, TRUE, TRUE, TRUE, TRUE),
    stringsAsFactors = FALSE
  )
  metrics_round = waterways:::calculate_sleep_metrics(data_manual)
  metrics_Round = waterways:::calculate_sleep_metrics(data_manual, rounder = "Round")
  metrics_raw = waterways:::calculate_sleep_metrics(data_manual, do_rounding = FALSE)
  testthat::expect_true(is.data.frame(metrics_round))
  testthat::expect_equal(metrics_round$efficiency, metrics_Round$efficiency)
  testthat::expect_true(all(c("avg_awakening_length", "nb_awakenings") %in% names(metrics_raw)))

  testthat::expect_equal(waterways:::rleid(c("a", "a", "b", "b", "a")), c(1L, 1L, 2L, 2L, 3L))

  renamed = waterways:::rename_timestamp(data.frame(time = 1:3))
  testthat::expect_true("timestamp" %in% names(renamed))
  testthat::expect_identical(waterways:::rename_timestamp(data.frame(timestamp = 1:3)), data.frame(timestamp = 1:3))

  sleep_stub = data.frame(
    time = time0 + 0:5 * 60,
    counts = c(0, 1, 2, 0, 2, 3),
    axis1 = c(0, 1, 2, 0, 2, 3),
    stringsAsFactors = FALSE
  )
  fake_cole_kripke = function(data) {
    data$sleep = "S"
    data
  }
  fake_tudor_locke = function(data) {
    data.frame(ok = TRUE)
  }

  no_bed_times = with_namespace_mock(
    "waterways",
    "ww_apply_cole_kripke",
    fake_cole_kripke,
    with_namespace_mock(
      "waterways",
      "ww_apply_tudor_locke",
      fake_tudor_locke,
      suppressMessages(suppressWarnings(ww_estimate_sleep(sleep_stub, verbose = FALSE)))
    )
  )
  testthat::expect_true(is.data.frame(no_bed_times))

  testthat::expect_message(
    testthat::expect_message(
      with_namespace_mock(
        "waterways",
        "ww_apply_cole_kripke",
        fake_cole_kripke,
        with_namespace_mock(
          "waterways",
          "ww_apply_tudor_locke",
          fake_tudor_locke,
          ww_estimate_sleep(sleep_stub, verbose = TRUE)
        )
      ),
      "Running ww_apply_cole_kripke"
    ),
    "Running ww_apply_tudor_locke"
  )

  sleep_stub_with_sleep = dplyr::mutate(sleep_stub, sleep = "S")
  no_sleep_column = with_namespace_mock(
    "waterways",
    "ww_apply_cole_kripke",
    fake_cole_kripke,
    with_namespace_mock(
      "waterways",
      "ww_apply_tudor_locke",
      fake_tudor_locke,
      suppressMessages(suppressWarnings(ww_estimate_sleep(sleep_stub_with_sleep, verbose = FALSE)))
    )
  )
  testthat::expect_true(is.data.frame(no_sleep_column))

  diary_small = data.frame(
    in_bed_time = time0,
    out_bed_time = time0 + 5 * 60,
    onset_time = time0 + 60,
    index = 1L,
    stringsAsFactors = FALSE
  )
  estimate = with_namespace_mock(
    "waterways",
    "ww_apply_cole_kripke",
    fake_cole_kripke,
    with_namespace_mock(
      "waterways",
      "ww_apply_tudor_locke",
      fake_tudor_locke,
      suppressMessages(suppressWarnings(ww_estimate_sleep(sleep_stub, data_bed_times = diary_small, verbose = FALSE)))
    )
  )
  testthat::expect_true(is.data.frame(estimate))

  diary_small_onset = data.frame(
    in_bed_time = time0,
    out_bed_time = time0 + 5 * 60,
    onset = time0 + 60,
    index = 1L,
    stringsAsFactors = FALSE
  )
  estimate_onset = with_namespace_mock(
    "waterways",
    "ww_apply_cole_kripke",
    fake_cole_kripke,
    with_namespace_mock(
      "waterways",
      "ww_apply_tudor_locke",
      fake_tudor_locke,
      suppressMessages(suppressWarnings(ww_estimate_sleep(sleep_stub, data_bed_times = diary_small_onset, verbose = FALSE)))
    )
  )
  testthat::expect_true(is.data.frame(estimate_onset))
})

test_that("gt3x reader internals are covered", {
  orig = waterways:::ww_read_gt3x_orig
  fake_no_header = function(path, asDataFrame = TRUE, imputeZeroes = TRUE, verbose = TRUE, ...) {
    data = data.frame(
      time = as.POSIXct(c("2025-03-11 00:00:00", "2025-03-11 00:00:01"), tz = "UTC"),
      X = c(0, 1),
      Y = c(0, 1),
      Z = c(0, 1)
    )
    attr(data, "header") = list(TimeZone = NULL)
    data
  }

  fake_with_header = function(path, asDataFrame = TRUE, imputeZeroes = TRUE, verbose = TRUE, ...) {
    data = data.frame(
      time = as.POSIXct(c(NA, "2025-03-11 00:00:01"), tz = "UTC"),
      X = c(0, 1),
      Y = c(0, 1),
      Z = c(0, 1)
    )
    attr(data, "header") = list(TimeZone = "-04:00:00")
    attr(data, "sample_rate") = 80
    data
  }

  fake_with_header_no_na = function(path, asDataFrame = TRUE, imputeZeroes = TRUE, verbose = TRUE, ...) {
    data = data.frame(
      time = as.POSIXct(c("2025-03-11 00:00:00", "2025-03-11 00:00:01"), tz = "UTC"),
      X = c(0, 1),
      Y = c(0, 1),
      Z = c(0, 1)
    )
    attr(data, "header") = list(TimeZone = "-04:00:00")
    attr(data, "sample_rate") = 80
    data
  }

  testthat::expect_warning(
    with_namespace_mock(
      "read.gt3x",
      "read.gt3x",
      fake_no_header,
      orig(path = "ignored", fill_zeroes = FALSE, apply_tz = FALSE, check_attributes = FALSE, verbose = TRUE)
    ),
    "No header found"
  )

  out_fill_zeroes = with_namespace_mock(
    "read.gt3x",
    "read.gt3x",
    fake_with_header_no_na,
    orig(path = "ignored", fill_zeroes = TRUE, apply_tz = FALSE, check_attributes = FALSE, verbose = FALSE)
  )
  testthat::expect_true(is.data.frame(out_fill_zeroes))

  suppressMessages(suppressWarnings(
    with_namespace_mock(
      "base",
      "requireNamespace",
      function(...) FALSE,
      with_namespace_mock(
        "read.gt3x",
        "read.gt3x",
        fake_with_header_no_na,
        orig(path = "ignored", fill_zeroes = TRUE, apply_tz = FALSE, check_attributes = FALSE, verbose = TRUE)
      )
    )
  ))

  testthat::expect_error(
    with_namespace_mock(
      "lubridate",
      "with_tz",
      function(x, tzone) {
        x[1] = NA
        x
      },
      with_namespace_mock(
        "lubridate",
        "force_tz",
        function(time, tz) time,
        with_namespace_mock(
          "read.gt3x",
          "read.gt3x",
          fake_with_header_no_na,
          orig(path = "ignored", fill_zeroes = FALSE, apply_tz = TRUE, check_attributes = FALSE, verbose = FALSE)
        )
      )
    ),
    "Applying timezone from offset created NA times"
  )

  out = with_namespace_mock(
    "read.gt3x",
    "read.gt3x",
    fake_with_header,
    orig(path = "ignored", fill_zeroes = FALSE, apply_tz = TRUE, check_attributes = TRUE, verbose = TRUE)
  )
  testthat::expect_true(is.data.frame(out))
  testthat::expect_equal(attr(out, "sample_rate"), 80)
})

test_that("epa walkability wrapper is covered", {
  fake_open = function(url) {
    list(url = url)
  }
  fake_select = function(arc_walk, geometry = TRUE, where = NULL, ...) {
    data.frame(
      GEOID10 = c("240054519002", "240054026041"),
      NatWalkInd = c(2, 18),
      stringsAsFactors = FALSE
    )
  }

  res_all = with_namespace_mock(
    "arcgislayers",
    "arc_open",
    fake_open,
    with_namespace_mock(
      "arcgislayers",
      "arc_select",
      fake_select,
      ww_epa_walkability(NULL, geometry = FALSE)
    )
  )
  testthat::expect_true("cat_walk_index" %in% names(res_all))

  testthat::expect_warning(
    with_namespace_mock(
      "arcgislayers",
      "arc_open",
      fake_open,
      with_namespace_mock(
        "arcgislayers",
        "arc_select",
        fake_select,
        ww_epa_walkability("123", geometry = FALSE)
      )
    ),
    "GEOID10 should be 12 characters long"
  )
})

test_that("sensorlogger edge branches are covered", {
  file = ww_example_sensorlogger_file()
  tfile = tempfile()
  extracted = unzip(file, exdir = tfile)
  csv_file = extracted[grepl("Compass[.]csv$", extracted)]

  testthat::expect_error(
    ww_read_sensorlogger(c(file, csv_file)),
    "only zip file or a vector of csv files"
  )

  empty_location = tempfile(fileext = ".csv")
  writeLines("time,seconds_elapsed,altitude,speedAccuracy,bearingAccuracy,latitude,altitudeAboveMeanSeaLevel,bearing,horizontalAccuracy,verticalAccuracy,longitude,speed", empty_location)
  testthat::expect_null(ww_read_sensorlogger_location(empty_location))
})
