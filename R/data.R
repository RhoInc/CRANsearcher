#' CRAN inventory snapshot
#'
#' Snapshot of CRAN web database inventory of packages for use offline.
#'
#' @format A data frame with 10,000+ rows and 6 columns:
#' \describe{
#'   \item{Package}{Package}
#'   \item{Version}{Version}
#'   \item{Title}{Title}
#'   \item{Description}{Description}
#'   \item{Published}{Published}
#'   \item{License}{License}
#'   \item{snapshot_date}{Date that database snapshot was taken.}
#'  }
#'
#' @source \url{https://CRAN.R-project.org/web/packages/}
"cran_inventory"
