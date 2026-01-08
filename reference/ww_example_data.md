# Paths to Example data

Simple wrapper of
[`base::system.file()`](https://rdrr.io/r/base/system.file.html) to get
the files included in the package

## Usage

``` r
ww_example_sensorlog_file()

ww_example_gt3x_file()

ww_example_sensorlogger_file()

ww_example_sensorlogger_location_file()
```

## Value

A character file name

## Examples

``` r
ww_example_sensorlog_file()
#> [1] "/home/runner/work/_temp/Library/waterways/extdata/SensorLogFiles_my_iOS_device_250311_14-55-58.zip"
ww_example_gt3x_file()
#> [1] "/home/runner/work/_temp/Library/waterways/extdata/TAS1H30182789_2025-03-11.gt3x.gz"
ww_example_sensorlogger_file()
#> [1] "/home/runner/work/_temp/Library/waterways/extdata/SensorLogger-2025-04-28_22-04-35.zip"
```
