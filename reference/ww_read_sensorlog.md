# Read SensorLog Data

Read SensorLog Data

## Usage

``` r
ww_read_sensorlog(file, verbose = FALSE, robust = FALSE)

ww_sensorlog_csv_spec()

ww_sensorlog_csv_colnames_mapping()
```

## Arguments

- file:

  A character vector of SensorLog files, usually from unzipping the file

- verbose:

  print diagnostic messages. Either logical or integer, where higher
  values are higher levels of verbosity.

- robust:

  if `TRUE` then
  [rewrite_sensorlog_csv](https://jhuwit.github.io/waterways/reference/rewrite_sensorlog_csv.md)
  is run on the data to try to fix any shifts with the data.

## Value

A `data.frame` of data

## Examples

``` r
file = ww_example_sensorlog_file()
df = ww_read_sensorlog(file)
head(df)
#> # A tibble: 6 × 14
#>   file   time  index timestamp   lat   lon altitude speed speed_accuracy accel_X
#>   <chr>  <chr> <dbl>     <dbl> <dbl> <dbl>    <dbl> <dbl>          <dbl>   <dbl>
#> 1 /tmp/… 2025…     1    1.74e9  39.3 -76.6     46.3    -1             -1  0.411 
#> 2 /tmp/… 2025…     2    1.74e9  39.3 -76.6     46.3    -1             -1  0.0908
#> 3 /tmp/… 2025…     3    1.74e9  39.3 -76.6     46.3    -1             -1  0.125 
#> 4 /tmp/… 2025…     4    1.74e9  39.3 -76.6     46.3    -1             -1  0.0636
#> 5 /tmp/… 2025…     5    1.74e9  39.3 -76.6     46.3    -1             -1  0.0993
#> 6 /tmp/… 2025…     6    1.74e9  39.3 -76.6     46.3    -1             -1  0.0702
#> # ℹ 4 more variables: accel_Y <dbl>, accel_Z <dbl>, lat_zero <lgl>,
#> #   lon_zero <lgl>
result = ww_process_sensorlog(df, check_data = FALSE, tz = "GMT")
out = ww_minute_sensorlog(result)
out = ww_summarize_sensorlog(result)
#> Warning: There was 1 warning in `dplyr::summarise()`.
#> ℹ In argument: `max_distance = max(distance, na.rm = TRUE)`.
#> ℹ In group 1: `date = 2025-03-11`.
#> Caused by warning in `max()`:
#> ! no non-missing arguments to max; returning -Inf
```
