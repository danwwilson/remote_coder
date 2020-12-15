#!/bin/bash

RUN install2.r --error --skipinstalled -r $CRAN \
  pak \
  && R -e 'pak::pkg_install("usethis"
                            "devtools",
                            "rmarkdown",
                            "RcppEigen",
                            "lme4",
                            "car",
                            "zoo",
                            "scales",
                            "reshape2",
                            "RPostgreSQL",
                            "RSQLite",
                            "Hmisc",
                            "scales",
                            "officer",
                            "flextable",
                            "xaringan",
                            "ggthemes",
                            "futile.logger",
                            "dplyr",
                            "readxl",
                            "writexl",
                            "drake",
                            "extrafont",
                            "visNetwork",
                            "clustermq",
                            "secret",
                            "XLConnect",
                            "fst",
                            "conflicted",
                            "dotenv",
                            "duckdb",
                            "pointblank",
                            "tidyverse/tidyverse",
                            "wilkelab/gridtext",
                            "milesmcbain/fnmate",
                            "milesmcbain/capsule",
                            "thedatacollective/tdcthemes")' \
  && R -e 'install.packages("data.table", type = "source", repos = "http://Rdatatable.github.io/data.table")' \
  && R -e 'remotes::install_gitlab("thedatacollective/tdcfun")' \
  && R -e 'remotes::install_gitlab("thedatacollective/templatermd")' \
  ##  && R -e 'remotes::install_github("stevenMMortimer/salesforcer", ref = "main")' \
  && R -e 'remotes::install_version("salesforcer", version = "0.1.4", repos = "http://cran.us.r-project.org")' \
  ##  && R -e 'remotes::install_github("gaborcsardi/dotenv")' \
  ##  && R -e 'remotes::install_github("r-lib/hugodown")' \
  && rm -rf /tmp/downloaded_packages/ \
  && rm -rf /tmp/*.tar.gz