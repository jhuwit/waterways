# Process SensorLog Daa

Process SensorLog Daa

## Usage

``` r
ww_process_sensorlog(
  data,
  lat = NULL,
  lon = NULL,
  dist_fun = geosphere::distVincentyEllipsoid,
  expected_timezone = NULL,
  check_data = TRUE,
  remove_cols = c("file", "index"),
  verbose = FALSE,
  ...,
  distance_cutoff = 180
)

ww_check_data(data, remove_cols = c("file", "index"))

ww_calculate_distance(
  data,
  lat,
  lon,
  distance_cutoff = 180,
  dist_fun = geosphere::distVincentyEllipsoid
)
```

## Arguments

- data:

  A `data.frame` from
  [ww_read_sensorlog](https://jhuwit.github.io/waterways/reference/ww_read_sensorlog.md)

- lat:

  Latitude of central point (e.g. home) to calculate distance. Set to
  `NULL` if distnace not to be run.

- lon:

  Longitude of central point (e.g. home) to calculate distance Set to
  `NULL` if distnace not to be run.

- dist_fun:

  Distance function to pass to
  [geosphere::distm](https://rdrr.io/pkg/geosphere/man/distm.html)

- expected_timezone:

  Expected Timezone based on the latitude/longitude of the data based on
  the lat/lon values from SensorLog ( e.g. `"America/New_York"`). Set to
  `NULL` if not to be checked.

- check_data:

  should ww_check_data be run?

- remove_cols:

  columns to remove from duplicate checking in ww_check_data. Default is
  `c("file", "index")`

- verbose:

  print diagnostic messages. Either logical or integer, where higher
  values are higher levels of verbosity.

- ...:

  additional arguments to pass to
  [ww_process_time](https://jhuwit.github.io/waterways/reference/ww_process_time.md),
  including `apply_tz` and `tz`

- distance_cutoff:

  Distance in meters to consider within home, in meters

## Value

A `data.frame` of transformed data

## Note

This calls ww_check_data, ww_calculate_distance, and
[ww_process_time](https://jhuwit.github.io/waterways/reference/ww_process_time.md)
