FROM rocker/r-ver:4.0.0

## Built from templates created by the Rocker Project
## For more information https://www.rocker-project.org

LABEL org.label-schema.license="GPL-2.0" \
      org.label-schema.vendor="The Data Collective" \
      maintainer="Dan Wilson <dan@thedatacollective.com.au>"

## This allows for direct access to rstudio server without passwords
## Do not use the below environment variables if placing on publicly
## exposed server (e.g. Amazon AWS)
ENV ROOT=TRUE
ENV PASSWORD=password
ENV DISABLE_AUTH=TRUE
ENV TZ=Australia/Brisbane

## Variables for the installation of RStudio
ENV S6_VERSION=v1.21.7.0
ENV RSTUDIO_VERSION=daily
ENV PATH=/usr/lib/rstudio-server/bin:$PATH

RUN apt-get update \
&&  apt-get install -y --no-install-recommends \
  libpq5

RUN /rocker_scripts/install_rstudio.sh
RUN /rocker_scripts/install_pandoc.sh
RUN /rocker_scripts/install_verse.sh

## Install tools to support desired packages
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    libgit2-dev \
    libxml2-dev \
    libcairo2-dev \
    liblapack-dev \
    liblapack3 \
    libopenblas-base \
    libpq-dev \
    libsqlite3-dev \
    libssh2-1-dev \
    unixodbc-dev \
    openssh-client \
    mdbtools \
    libsnappy-dev \
    autoconf \
    automake \
    libtool \
    python-dev \
    python3-pip \
    pkg-config \
    p7zip-full \
    libudunits2-dev \
    tzdata \
  && pip3 install -U radian \
  && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
  && dpkg-reconfigure -f noninteractive tzdata \
  && rm -rf /var/lib/apt/lists/*

## add regularly used packages
## COPY scripts /rocker_scripts
## RUN /rocker_scripts/install_packages.sh
RUN install2.r --error --skipinstalled -r $CRAN \
  pak \
  && R -e 'pak::pkg_install("usethis", \
                            "devtools", \
                            "rmarkdown", \
                            "RcppEigen", \
                            "lme4", \
                            "car", \
                            "zoo", \
                            "scales", \
                            "reshape2", \
                            "RPostgreSQL", \
                            "RSQLite", \
                            "Hmisc", \
                            "scales", \
                            "officer", \
                            "flextable", \
                            "xaringan", \
                            "ggthemes", \
                            "futile.logger", \
                            "dplyr", \
                            "readxl", \
                            "writexl", \
                            "drake", \
                            "extrafont", \
                            "visNetwork", \
                            "clustermq", \
                            "secret", \
                            "XLConnect", \
                            "fst", \
                            "conflicted", \
                            "dotenv", \
                            "duckdb", \
                            "pointblank", \
                            "tidyverse/tidyverse", \
                            "wilkelab/gridtext", \
                            "milesmcbain/fnmate", \
                            "milesmcbain/capsule", \
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

RUN mkdir -p etc/rstudio/keybindings/ \
 && rm -r /home/rstudio/.rstudio/monitored/user-settings \
 && mkdir -p /home/rstudio/.config/rstudio/keybindings/ \
 && echo 'auth-timeout-minutes=0 \
          \nauth-stay-signed-in-days=30' \
          > /etc/rstudio/rserver.conf

# put settings into main rstudio folders
COPY settings/addins.json /home/rstudio/.config/rstudio/keybindings/
COPY settings/rstudio-prefs.json etc/rstudio/
##COPY settings/rserver.conf etc/rstudio/

RUN chown -R rstudio:staff /home/rstudio/ \
   && chmod -R 777 /home/rstudio/

## copy fonts to make available for use in rstudio and documents
## Update font cache once copied
COPY fonts /usr/share/fonts
COPY fonts /etc/rstudio/fonts
RUN fc-cache -f -v

## Add /data volume by default
VOLUME /data
VOLUME /home/rstudio/.ssh

## expose port for rstudio server
EXPOSE 8787

CMD /init
