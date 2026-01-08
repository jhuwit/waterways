# Process the Time data from SensorLog and Compare to an Expected Timezone

Process the Time data from SensorLog and Compare to an Expected Timezone

## Usage

``` r
ww_process_time(
  data,
  expected_timezone = "America/New_York",
  tz = "GMT",
  apply_tz = TRUE,
  check_data = TRUE,
  verbose = FALSE,
  ...
)
```

## Arguments

- data:

  A `data.frame` from
  [ww_read_sensorlog](https://jhuwit.github.io/waterways/reference/ww_read_sensorlog.md)

- expected_timezone:

  Expected Timezone based on the latitude/longitude of the data based on
  the lat/lon values from SensorLog ( e.g. `"America/New_York"`). Set to
  `NULL` if not to be checked.

- tz:

  timezone to project the data into. Keeping as `GMT` and should have
  same value for `apply_tz` to agree (caution: always check data) with
  ActiGraph, passed to
  [lubridate::as_datetime](https://lubridate.tidyverse.org/reference/as_date.html).

- apply_tz:

  Apply the timezone from the timezone shift from the timezone, e.g.
  "2025-03-11T14:44:11-04:00" becomes "2025-03-11T18:44:11" if
  `apply_tz = TRUE`, but "2025-03-11T14:44:11" if `apply_tz = FALSE`.

- check_data:

  if `TRUE` any duplicates for time are checked for.

- verbose:

  print diagnostic messages. Either logical or integer, where higher
  values are higher levels of verbosity.

- ...:

  additional arguments to pass to
  [`lutz::tz_lookup_coords()`](http://andyteucher.ca/lutz/reference/tz_lookup_coords.md)

## Value

A `data.frame`
