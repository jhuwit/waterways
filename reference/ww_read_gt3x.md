# Read GT3X file

Read GT3X file

## Usage

``` r
ww_read_gt3x(
  path,
  asDataFrame = TRUE,
  imputeZeroes = TRUE,
  verbose = TRUE,
  ...,
  fill_zeroes = TRUE,
  apply_tz = TRUE,
  check_attributes = TRUE,
  tz = "GMT"
)
```

## Arguments

- path:

  Path to gt3x file

- asDataFrame:

  convert to an `activity_df`, see `as.data.frame.activity`

- imputeZeroes:

  Impute zeros in case there are missingness? Default is `FALSE`, in
  which case the time series will be incomplete in case there is
  missingness.

- verbose:

  print diagnostic messages, higher values = more verbosity.

- ...:

  additional arguments to pass to
  [`read.gt3x::read.gt3x()`](https://rdrr.io/pkg/read.gt3x/man/read.gt3x.html)

- fill_zeroes:

  Rows with all zeros will be filled in with the last observation
  carried forward as is done with ActiLife. Recommended

- apply_tz:

  Apply the timezone from the header `TimeZone` attribute

- check_attributes:

  Check that the attributes are included This is a sanity check,
  including checking that `sample_rate` is in the attributes.

- tz:

  timezone to project the data into. The data read in via
  [`read.gt3x::read.gt3x()`](https://rdrr.io/pkg/read.gt3x/man/read.gt3x.html)
  says the timezone is GMT, but the time values is in the native
  timezone. So this data is projected into the correct time zone and
  then forced into the timezone given by `tz`. Set to `NULL` to not
  apply this forcing.

## Value

A `data.frame`

## Examples

``` r
path = ww_example_gt3x_file()
ac = ww_read_gt3x(path, verbose = FALSE)
```
