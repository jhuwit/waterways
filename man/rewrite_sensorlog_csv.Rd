% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rewrite_csv.R
\name{rewrite_sensorlog_csv}
\alias{rewrite_sensorlog_csv}
\title{Rewrite a CSV that may have issues with export from SensorLog}
\usage{
rewrite_sensorlog_csv(
  file,
  outfile = tempfile(fileext = ".csv"),
  verbose = FALSE
)
}
\arguments{
\item{file}{Input CSV file}

\item{outfile}{Output CSV file}

\item{verbose}{Print Diagnostic messages}
}
\value{
A file path to the new CSV
}
\description{
Rewrite a CSV that may have issues with export from SensorLog
}
\examples{
sl_file = ww_example_sensorlog_file()
tfile = tempfile()
files = utils::unzip(sl_file, exdir = tfile)
result = rewrite_sensorlog_csv(files)
}
