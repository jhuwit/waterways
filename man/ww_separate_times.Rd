% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ww_separate_times.R
\name{ww_separate_times}
\alias{ww_separate_times}
\title{Separate Times into Date, Hour, and Minute}
\usage{
ww_separate_times(data)
}
\arguments{
\item{data}{a \code{data.frame} with a \code{time} column}
}
\value{
A \code{data.frame} with date, hour, minute, and day columns
}
\description{
Separate Times into Date, Hour, and Minute
}
\examples{
df = data.frame(
  time = seq(Sys.time(), Sys.time() + 1000, by = 1)
)
ww_separate_times(df)
}
