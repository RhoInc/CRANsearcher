#library(tools)
library(dplyr)

getPackages <- function() {
  contrib.url(getOption("repos")["CRAN"], "source")
  description <- sprintf("%s/web/packages/packages.rds", getOption("repos")["CRAN"])
  con <- if(substring(description, 1L, 7L) == "file://") {
    file(description, "rb")
  } else {
    url(description, "rb")
  }
  on.exit(close(con))
  db <- readRDS(gzcon(con))
  rownames(db) <- NULL
  db[, c("Package", "Version","Title","Description","Published","License")]}

cran_inventory <- getPackages()
cran_inventory <- data.frame(cran_inventory)

devtools::use_data(cran_inventory)

