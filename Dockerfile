FROM rocker/shiny-verse

MAINTAINER Ira Cooke "ira.cooke@jcu.edu.au"

RUN apt-get update && apt-get install -y \
    sudo \
    ncbi-blast+

RUN R -e "install.packages(c('BiocManager','DT','dbplyr'), repos='https://cloud.r-project.org/')"

RUN R -e "BiocManager::install('ComplexHeatmap')"
RUN R -e "BiocManager::install('InteractiveComplexHeatmap')"

# copy the app to the image
RUN mkdir /srv/shiny-server/amil2_dev
RUN mkdir /srv/shiny-server/amil2_dev/shiny_data

COPY app.R /srv/shiny-server/amil2_dev/app.R
COPY plot_genes.R /srv/shiny-server/amil2_dev/plot_genes.R
COPY blast.R /srv/shiny-server/amil2_dev/blast.R
COPY myserver.R /srv/shiny-server/amil2_dev/myserver.R
COPY shiny.conf /etc/shiny-server/shiny-server.conf

