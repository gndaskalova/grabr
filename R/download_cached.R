# for use inside grab(), download all the files needed for this query
download_cached <- function (lookup) {
  urls <- unique(lookup$url)
  for (url in urls) {
    download_source(url, url_to_name(url))
  }
}

# create a unique name based on this url
url_to_name <- function (url) {
  strsplit(url, "://")[[1]][2]
}