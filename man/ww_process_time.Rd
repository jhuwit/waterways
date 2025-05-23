% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ww_process_time.R
\name{ww_process_time}
\alias{ww_process_time}
\title{Process the Time data from SensorLog and Compare to an Expected Timezone}
\usage{
ww_process_time(
  data,
  expected_timezone = "America/New_York",
  tz = "GMT",
  apply_tz = TRUE,
  check_data = TRUE,
  verbose = FALSE,
  ...
)
}
\arguments{
\item{data}{A \code{data.frame} from \link{ww_read_sensorlog}}

\item{expected_timezone}{Expected Timezone based on the latitude/longitude
of the data based on the lat/lon values from SensorLog (
e.g. \code{"America/New_York"}).  Set to
\code{NULL} if not to be checked.}

\item{tz}{timezone to project the data into.  Keeping as \code{GMT} and should
have same value for \code{apply_tz} to agree (caution: always check data)
with ActiGraph, passed to \link[lubridate:as_date]{lubridate::as_datetime}.}

\item{apply_tz}{Apply the timezone from the timezone shift from the timezone,
e.g. "2025-03-11T14:44:11-04:00" becomes "2025-03-11T18:44:11" if
\code{apply_tz = TRUE}, but "2025-03-11T14:44:11" if \code{apply_tz = FALSE}.}

\item{check_data}{if \code{TRUE} any duplicates for time are checked for.}

\item{verbose}{print diagnostic messages.  Either logical or integer, where
higher values are higher levels of verbosity.}

\item{...}{additional arguments to pass to \code{\link[lutz:tz_lookup_coords]{lutz::tz_lookup_coords()}}}
}
\value{
A \code{data.frame}
}
\description{
Process the Time data from SensorLog and Compare to an Expected Timezone
}
