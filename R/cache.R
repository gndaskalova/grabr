# use a cache for dowloaded files, so they only need to be downloaded once

# do some magic to create a cache that is visible to all internal functions, and
# can be changed by the user

# an environment, defined in the package namespace
cache <- new.env()

# create an object in that environment with the file path (by default a
# temporary directory)
cache$data_store <- tempdir()


# user-exposed function to get and set the data store location

#' @name data_store
#' @title Get and Set the Location of the Data Store
#'
#' @param path an optional character string giving a new file path in which to
#'   store the data
#'
#' @return a character string giving the current location of the data store if
#'   \code{path} was specified, this will be returned invisibly
#'
#' @export
#'
#' @examples
#' # list the current data store location
#' data_store()
#' old_store <- data_store()
#'
#' # set it to a new value
#' data_store("~/a_new_path")
#' data_store()
data_store <- function (path = NULL) {
  if (is.null(path)) {
    return (cache$data_store)
  } else {
    cache$data_store <- path
    return (invisible(cache$data_store))
  }
}

# what is the file with this name
source_file <- function (name) {
  file.path(data_store(), name)
}

# has this source been cached already
source_cached <- function (name) {
  file_name <- source_file(name)
  file.exists(file_name)
}

# delete a downloaded source, if it exists
delete_source <- function (name) {
  if (source_cached(name)) {
    file_name <- source_file(name)
    file.remove(file_name)
  }
}

# download a source and store it with a name (unless it has already been
# downloaded)
download_source <- function (source, name) {
  if (!source_cached(name)) {
    file_name <- source_file(name)
    download.file(source, file_name)
  }
}


# load a cached file as a raster
load_source <- function (name) {
  file_name <- source_file(name)
  raster(file_name)
}

# usage:

# download_source("some_url", "name")
# load_source("name")