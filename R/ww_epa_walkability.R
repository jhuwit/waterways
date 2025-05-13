epa_arc = function() {
  url <- "https://geodata.epa.gov/arcgis/rest/services/OA/WalkabilityIndex/MapServer/0"

  walk_arc <- arcgislayers::arc_open(url)
}

#' Get EPA Walkability Index
#'
#' @param geoid GEOID10 of the area of interest.  This should be a 12 character string.
#' If `NULL`, then all GEOIDs are selected (warning: this can be a lot of data, take a while,
#' use with caution).
#' @param geometry Should geometry be returned?  Passed to [arcgislayers::arc_select()]
#' @param ... additional arguments to pass to [arcgislayers::arc_select()]
#' @note
#' See
#' \url{https://geodata.epa.gov/arcgis/rest/services/OA/WalkabilityIndex/MapServer/0}
#'
#' @returns A `data.frame` of results
#' @export
#'
#' @examplesIf rlang::is_installed("arcgislayers")
#' ww_epa_walkability(c("240054519002", "240054026041", "245102303002"))
ww_epa_walkability = function(geoid,
                              geometry = TRUE,
                              ...) {
  NatWalkInd = NULL
  rm(list = c("NatWalkInd"))
  rlang::check_installed("arcgislayers")
  arc_walk = epa_arc()
  if (!is.null(geoid)) {
    if (!all(nchar(geoid) == 12)) {
      warning("GEOID10 should be 12 characters long")
    }
    ids = paste0("'", as.character(geoid), "'")
    in_clause = paste0("(", paste(ids, collapse = ", "), ")")
    where = paste0("GEOID10 IN ", in_clause)
  } else {
    where = NULL
  }
  res = arcgislayers::arc_select(
    arc_walk,
    geometry = geometry,
    where = where,
    ...)
  if (nrow(res) > 0 && assertthat::has_name(res, "NatWalkInd")) {
    breaks = c(1, 5.75, 10.5, 15.25, 20)
    res = res %>%
      dplyr::mutate(
        cat_walk_index = cut(NatWalkInd, breaks = breaks, include.lowest = TRUE, right = TRUE)
      )
  }
  return(res)
}




