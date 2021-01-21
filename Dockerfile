FROM collegevine/r-prod-base

RUN Rscript -e 'install.packages(c("radiant.data", "maps", "mapdata", "viridis", "shinyjs", "see"))'

RUN mkdir app
COPY . /app

EXPOSE 3838

CMD ["R", "-e", "shiny::runApp('/app', host = '0.0.0.0', port = 3838)"]
