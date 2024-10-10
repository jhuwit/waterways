unzip_file = function(zip_file) {
  tdir = tempfile()
  dir.create(tdir)
  files = utils::unzip(zipfile = zip_file, exdir = tdir)
  files
}

strip_hour_shift = function(x) {
  x = sub("[+]", " +", x)
  x = sub("-(\\d\\d:00)$", " -\\1", x)
  xx = strsplit(x, split = " ")
  l = sapply(xx, length)
  stopifnot(all(l >= 2))
  xx = sapply(xx, function(r) {
    paste(r[1:2], collapse = " ")
  })
  xx
}

read_csv_safe = function(..., guess_max = Inf) {
  x = readr::read_csv(..., guess_max = guess_max)
  p = readr::problems(x)
  cn = list(...)$col_names
  if (is.null(cn)) {
    cn = TRUE
  }
  if (nrow(p) > 0) {
    print(p)
    rows = unique(p$row)
    if (cn) {
      rows = rows - 1
    }
    bad_data = x[rows, unique(p$col)]
    print("Bad Data:")
    print(bad_data)
  }
  readr::stop_for_problems(x)
  x
}



as_convert_safe = function(x, ..., func = lubridate::as_datetime) {
  nax = is.na(x)
  xx = func(x, ...)
  naxx = is.na(xx)
  any_na = !nax & naxx
  if (any(any_na)) {
    message("Conversion not done for:")
    print(x[any_na])
    stop("conversion failed")
  }
  xx
}

as_date_safe = function(x, ...) {
  as_convert_safe(x, ..., func = lubridate::as_date)
}

as_datetime_safe = function(x, ...) {
  as_convert_safe(x, ..., func = lubridate::as_datetime)
}
