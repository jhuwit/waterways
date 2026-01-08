# Process SensorLog Daa

Process SensorLog Daa

## Usage

``` r
ww_calculate_counts(data, epoch = 60L, lfe_select = FALSE, verbose = TRUE)

ww_calculate_wear(
  data,
  method = c("choi", "troiano"),
  use_magnitude = TRUE,
  ...
)

ww_calculate_nonwear(
  data,
  method = c("choi", "troiano"),
  use_magnitude = TRUE,
  ...
)

ww_process_gt3x(
  data,
  lfe_select = FALSE,
  method = c("choi", "troiano"),
  use_magnitude = TRUE,
  verbose = TRUE,
  ...
)

ww_apply_cole_kripke(data)

ww_apply_tudor_locke(data, ...)

ww_estimate_sleep(data, data_bed_times = NULL, verbose = TRUE)
```

## Arguments

- data:

  A `data.frame` from
  [ww_read_gt3x](https://jhuwit.github.io/waterways/reference/ww_read_gt3x.md)

- epoch:

  epoch length in seconds. Default is 60 seconds. See
  [agcounts::calculate_counts](https://rdrr.io/pkg/agcounts/man/calculate_counts.html)

- lfe_select:

  Apply the Actigraph Low Frequency Extension filter. See
  [agcounts::calculate_counts](https://rdrr.io/pkg/agcounts/man/calculate_counts.html)
  higher values are higher levels of verbosity.

- verbose:

  print diagnostic messages. Either logical or integer, where

- method:

  Method for detecting non-wear, either "choi" or "troiano",
  corresponding to
  [actigraph.sleepr::apply_choi](https://rdrr.io/pkg/actigraph.sleepr/man/apply_choi.html)
  or
  [actigraph.sleepr::apply_troiano](https://rdrr.io/pkg/actigraph.sleepr/man/apply_troiano.html)

- use_magnitude:

  If `TRUE`, the magnitude of the vector (axis1, axis2, axis3) is used
  to measure activity; otherwise the axis1 value is used.

- ...:

  additional arguments to pass to `actigraph.sleepr` function

- data_bed_times:

  A `data.frame` containing bed times with columns `in_bed_time`,
  `out_bed_time`, and `onset` or `onset_time`. If `NULL`,
  ww_apply_tudor_locke is used to estimate sleep metrics.

## Value

A `data.frame` of transformed data

## Note

This calls
[ww_check_data](https://jhuwit.github.io/waterways/reference/ww_process_sensorlog.md),
[ww_calculate_distance](https://jhuwit.github.io/waterways/reference/ww_process_sensorlog.md),
and
[ww_process_time](https://jhuwit.github.io/waterways/reference/ww_process_time.md)

For `ww_process_gt3x`, the `...` argument are passed to
[ww_read_gt3x](https://jhuwit.github.io/waterways/reference/ww_read_gt3x.md)

## Examples

``` r
path = ww_example_gt3x_file()
ac = ww_read_gt3x(path, verbose = FALSE)
out = ww_calculate_counts(ac)
#> Downloading uv...
#> Done!
#> [1] "Creating Downsampled Data"
#> [1] "Filtering Data"
#> [1] "Trimming Data"
#> [1] "Getting data back to 10Hz for accumulation"
#> [1] "Summing epochs"
```
