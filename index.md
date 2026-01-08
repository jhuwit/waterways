# waterways

The goal of waterways is to provide code to read and analyze SensorLog
data along with ActiGraph data for the OCEANS/WAVES studies.

## Installation

You can install the development version of waterways from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("jhuwit/waterways")
```

## Example

### Read in GT3X data:

``` r
library(waterways)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
```

``` r

file_gt3x = ww_example_gt3x_file()
file_gt3x
#> [1] "/Library/Frameworks/R.framework/Versions/4.4-x86_64/Resources/library/waterways/extdata/TAS1H30182789_2025-03-11.gt3x.gz"
ag = ww_read_gt3x(file_gt3x, verbose = FALSE, apply_tz = FALSE)
head(ag)
#>                  time      X     Y     Z
#> 1 2025-03-11 13:45:00 -0.270 0.910 0.352
#> 2 2025-03-11 13:45:00 -0.266 0.895 0.359
#> 3 2025-03-11 13:45:00 -0.270 0.887 0.375
#> 4 2025-03-11 13:45:00 -0.281 0.875 0.391
#> 5 2025-03-11 13:45:00 -0.289 0.863 0.406
#> 6 2025-03-11 13:45:00 -0.285 0.859 0.418
lubridate::tz(ag$time)
#> [1] "GMT"
```

### Reading in the data

The data is read in using the `ww_read_sensorlog` function:

``` r
file = ww_example_sensorlog_file()
df = ww_read_sensorlog(file, robust = FALSE)
df = df %>% select(-file) # we don't need to see which file this came from
head(df)
#> # A tibble: 6 × 13
#>   time         index timestamp   lat   lon altitude speed speed_accuracy accel_X
#>   <chr>        <dbl>     <dbl> <dbl> <dbl>    <dbl> <dbl>          <dbl>   <dbl>
#> 1 2025-03-11T…     1    1.74e9  39.3 -76.6     46.3    -1             -1  0.411 
#> 2 2025-03-11T…     2    1.74e9  39.3 -76.6     46.3    -1             -1  0.0908
#> 3 2025-03-11T…     3    1.74e9  39.3 -76.6     46.3    -1             -1  0.125 
#> 4 2025-03-11T…     4    1.74e9  39.3 -76.6     46.3    -1             -1  0.0636
#> 5 2025-03-11T…     5    1.74e9  39.3 -76.6     46.3    -1             -1  0.0993
#> 6 2025-03-11T…     6    1.74e9  39.3 -76.6     46.3    -1             -1  0.0702
#> # ℹ 4 more variables: accel_Y <dbl>, accel_Z <dbl>, lat_zero <lgl>,
#> #   lon_zero <lgl>
```

``` r
df %>% 
  add_count(time) %>% 
  filter(n > 1) %>% 
  select(time, lat, lon, starts_with("accel"))
#> # A tibble: 8 × 6
#>   time                            lat   lon accel_X accel_Y  accel_Z
#>   <chr>                         <dbl> <dbl>   <dbl>   <dbl>    <dbl>
#> 1 2025-03-11T14:44:14.795-04:00  39.3 -76.6 -0.705    0.891  0.427  
#> 2 2025-03-11T14:44:14.795-04:00  39.3 -76.6 -1.02     0.667  0.405  
#> 3 2025-03-11T14:44:14.795-04:00  39.3 -76.6 -0.641    0.833 -0.0961 
#> 4 2025-03-11T14:44:14.796-04:00  39.3 -76.6 -0.989    0.441  0.0263 
#> 5 2025-03-11T14:44:14.796-04:00  39.3 -76.6 -0.808    0.591 -0.00647
#> 6 2025-03-11T14:44:14.796-04:00  39.3 -76.6 -0.213    0.354 -0.0787 
#> 7 2025-03-11T14:44:14.797-04:00  39.3 -76.6 -0.0179   0.432 -0.0820 
#> 8 2025-03-11T14:44:14.797-04:00  39.3 -76.6  0.0611   0.418  0.0770
```

``` r
df = ww_process_sensorlog(df, check_data = FALSE, apply_tz = FALSE)
df
#> # A tibble: 11,578 × 18
#>    time                index timestamp             lat   lon altitude speed
#>    <dttm>              <dbl> <dttm>              <dbl> <dbl>    <dbl> <dbl>
#>  1 2025-03-11 14:44:11     1 2025-03-11 18:44:07  39.3 -76.6     46.3    -1
#>  2 2025-03-11 14:44:11     2 2025-03-11 18:44:07  39.3 -76.6     46.3    -1
#>  3 2025-03-11 14:44:11     3 2025-03-11 18:44:07  39.3 -76.6     46.3    -1
#>  4 2025-03-11 14:44:12     4 2025-03-11 18:44:07  39.3 -76.6     46.3    -1
#>  5 2025-03-11 14:44:12     5 2025-03-11 18:44:07  39.3 -76.6     46.3    -1
#>  6 2025-03-11 14:44:12     6 2025-03-11 18:44:07  39.3 -76.6     46.3    -1
#>  7 2025-03-11 14:44:12     7 2025-03-11 18:44:07  39.3 -76.6     46.3    -1
#>  8 2025-03-11 14:44:12     8 2025-03-11 18:44:07  39.3 -76.6     46.3    -1
#>  9 2025-03-11 14:44:12     9 2025-03-11 18:44:07  39.3 -76.6     46.3    -1
#> 10 2025-03-11 14:44:12    10 2025-03-11 18:44:07  39.3 -76.6     46.3    -1
#> # ℹ 11,568 more rows
#> # ℹ 11 more variables: speed_accuracy <dbl>, accel_X <dbl>, accel_Y <dbl>,
#> #   accel_Z <dbl>, lat_zero <lgl>, lon_zero <lgl>, distance <dbl>,
#> #   is_within_home <lgl>, distance_traveled <dbl>, timezone_estimated <chr>,
#> #   char_time <chr>
```

``` r
df_min = ww_minute_sensorlog(df)
df_min
#> # A tibble: 12 × 16
#>    time                max_speed   lat   lon speed accel_X accel_Y accel_Z
#>    <dttm>                  <dbl> <dbl> <dbl> <dbl>   <dbl>   <dbl>   <dbl>
#>  1 2025-03-11 14:44:00        -1  39.3 -76.6    -1 -0.0178   0.964  0.0182
#>  2 2025-03-11 14:45:00        -1  39.3 -76.6    -1 -0.0665   1.01   0.0577
#>  3 2025-03-11 14:46:00        -1  39.3 -76.6    -1 -0.0547   1.00   0.0250
#>  4 2025-03-11 14:47:00        -1  39.3 -76.6    -1 -0.0843   1.01   0.0450
#>  5 2025-03-11 14:48:00        -1  39.3 -76.6    -1 -0.0808   1.01   0.0468
#>  6 2025-03-11 14:49:00        -1  39.3 -76.6    -1 -0.0901   1.01   0.0411
#>  7 2025-03-11 14:50:00        -1  39.3 -76.6    -1 -0.0842   1.01   0.0512
#>  8 2025-03-11 14:51:00        -1  39.3 -76.6    -1 -0.0882   1.01   0.0466
#>  9 2025-03-11 14:52:00        -1  39.3 -76.6    -1 -0.0877   1.01   0.0430
#> 10 2025-03-11 14:53:00        -1  39.3 -76.6    -1 -0.0876   1.01   0.0494
#> 11 2025-03-11 14:54:00        -1  39.3 -76.6    -1 -0.0866   1.01   0.0395
#> 12 2025-03-11 14:55:00        -1  39.3 -76.6    -1 -0.0652   0.829 -0.0668
#> # ℹ 8 more variables: distance <dbl>, is_within_home <lgl>,
#> #   distance_traveled <dbl>, vm <dbl>, enmo <dbl>, lat_zero <lgl>,
#> #   lon_zero <lgl>, in_sensorlog <lgl>
```
