# Get Census Tract FIPS codes

Get Census Tract FIPS codes

## Usage

``` r
ww_fips15(state, county, tract, block = NA)

ww_fips12(state, county, tract, block = NA)
```

## Arguments

- state:

  2-digit state FIPS code

- county:

  3-digit state FIPS code

- tract:

  6-digit tract FIPS code

- block:

  6-digit block FIPS code. If omitted or `NA`, 12-digit codes returned

## Value

A 12-to-15 digit FIPS code

## Examples

``` r
ww_fips15(24, 510, 60400)
#> Warning: Some have NA block - giving those tract level
#> [1] "24510060400"
ww_fips15(24, 510, 60400, block = 2002)
#> [1] "245100604002002"
ww_fips12(24, 510, 60400, block = 2002)
#> [1] "245100604002"
```
