#' Get Census Tract FIPS codes
#'
#' @param state 2-digit state FIPS code
#' @param county 3-digit state FIPS code
#' @param tract 6-digit tract FIPS code
#' @param block 6-digit block FIPS code.  If omitted or `NA`, 12-digit codes returned
#'
#' @returns A 12-to-15 digit FIPS code
#' @export
#' @rdname ww_fips
#'
#' @examples
#' ww_fips15(24, 510, 60400)
#' ww_fips15(24, 510, 60400, block = 2002)
#' ww_fips12(24, 510, 60400, block = 2002)
ww_fips15 = function(
    state,
    county,
    tract,
    block = NA) {
  na_block = is.na(block)
  if (any(na_block)) {
    warning(paste0("Some have NA block - giving those tract level"))
  }
  fips15 = sprintf("%02.0f%03.0f%06.0f",
                   state,
                   county,
                   tract)
  fips15[!na_block] = sprintf("%s%04.0f",
                              fips15[!na_block],
                              block[!na_block])
  fips15
}

#' @export
#' @rdname ww_fips
ww_fips12 = function(
    state,
    county,
    tract,
    block = NA) {
  fips15 = ww_fips15(
    state = state,
    county = county,
    tract = tract,
    block = block)
  fips12 = substr(fips15, 1, 12)
  fips12
}
