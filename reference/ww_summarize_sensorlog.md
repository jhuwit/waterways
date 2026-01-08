# Summarize SensorLog Data

Summarize SensorLog Data

## Usage

``` r
ww_summarize_sensorlog(data)

ww_summarise_sensorlog(data)

ww_minute_sensorlog(data, seconds = 60L)

ww_summarize_distance_sensorlog(data)
```

## Arguments

- data:

  `data.frame` of the data, output from `ww_process_sensorlog`

- seconds:

  integer of the number of seconds to summarize the data for the
  "minute" level. Usually 1 minute/60 seconds. For
  `ww_summarize_distance_sensorlog`, summarization is done depending on
  how the data is grouped.

## Value

The `data.frame` with the summarized data for each date
