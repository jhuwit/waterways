# Read SensorLogger Data

Read SensorLogger Data

## Usage

``` r
ww_sensorlogger_location_colnames_mapping()

ww_sensorlogger_location_spec()

ww_read_sensorlogger_location(file, ...)

ww_read_sensorlogger(file, verbose = FALSE, ...)

ww_read_sensorlogger_general(file, ..., verbose = FALSE)

ww_read_sensorlogger_accelerometer(file, ..., verbose = FALSE)

ww_read_sensorlogger_accelerometer_uncalibrated(file, ..., verbose = FALSE)

ww_read_sensorlogger_annotation(file, ..., verbose = FALSE)

ww_read_sensorlogger_battery(file, ..., verbose = FALSE)

ww_read_sensorlogger_gravity(file, ..., verbose = FALSE)

ww_read_sensorlogger_gyroscope_uncalibrated(file, ..., verbose = FALSE)

ww_read_sensorlogger_metadata(file, ..., verbose = FALSE)

ww_read_sensorlogger_orientation(file, ..., verbose = FALSE)

ww_read_sensorlogger_pedometer(file, ..., verbose = FALSE)
```

## Arguments

- file:

  A character vector of SensorLogger files, usually from unzipping the
  file, or a zip file of SensorLogger files

- ...:

  additional arguments to pass to
  [`readr::read_csv()`](https://readr.tidyverse.org/reference/read_delim.html).
  If `verbose = FALSE`, then `progress = FALSE` and
  `show_col_types = FALSE`, unless otherwise overridden

- verbose:

  print diagnostic messages. Either logical or integer, where higher
  values are higher levels of verbosity.

## Value

A `data.frame` of data
