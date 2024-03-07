FROM rocker/geospatial:4.3.2

ENV NB_USER rstudio
ENV NB_UID 1000
ENV CONDA_DIR /srv/conda
ENV GRADEBOOK_DIR /app/gradebook

# Set ENV for all programs...
ENV PATH ${CONDA_DIR}/bin:$PATH

# Pick up rocker's default TZ
ENV TZ=Etc/UTC

# And set ENV for R! It doesn't read from the environment...
RUN echo "TZ=${TZ}" >> /usr/local/lib/R/etc/Renviron.site
RUN echo "PATH=${PATH}" >> /usr/local/lib/R/etc/Renviron.site

# Add PATH to /etc/profile so it gets picked up by the terminal
RUN echo "PATH=${PATH}" >> /etc/profile
RUN echo "export PATH" >> /etc/profile

ENV HOME /home/${NB_USER}

WORKDIR ${HOME}

# texlive-xetex pulls in texlive-latex-extra > texlive-latex-recommended
# We use Ubuntu's TeX because rocker's doesn't have most packages by default,
# and we don't want them to be downloaded on demand by students.
RUN apt-get update && \
    apt-get install --yes \
            less \
            fonts-symbola \
            tini \
            pandoc \
            texlive-xetex \
            texlive-fonts-recommended \
            # provides FandolSong-Regular.otf for issue #2714
            texlive-lang-chinese \
            texlive-plain-generic \
            npm > /dev/null && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV SHINY_SERVER_URL https://download3.rstudio.org/ubuntu-18.04/x86_64/shiny-server-1.5.19.995-amd64.deb
RUN curl --silent --location --fail ${SHINY_SERVER_URL} > /tmp/shiny-server.deb && \
    apt install --no-install-recommends --yes /tmp/shiny-server.deb && \
    rm /tmp/shiny-server.deb

# Install jupyter stack, for use on a jupyterhub
COPY install-mambaforge.bash /tmp/install-mambaforge.bash
RUN /tmp/install-mambaforge.bash

RUN install -d -o ${NB_USER} ${GRADEBOOK_DIR}

RUN rm -rf /home/${NB_USER}/.cache

USER ${NB_USER}

COPY environment.yml /tmp/environment.yml
RUN mamba env update -p ${CONDA_DIR} -f /tmp/environment.yml && \
    mamba clean -afy

# install dependencies (this is not reproducible)
RUN install2.r DT shinydashboard shinyWidgets Hmisc purrr markdown devtools

# install gradebook library
RUN R -e 'devtools::install_github("gradebook-dev/gradebook", ref = "v030")'

COPY install-gradebook-app.sh /tmp/
RUN bash /tmp/install-gradebook-app.sh pr 52

COPY shiny.conf ${GRADEBOOK_DIR}/gradebook-app/R/shiny.conf

# Our custom app port
EXPOSE 3839
# For using jupyter to proxy R or shiny
EXPOSE 8888

WORKDIR ${GRADEBOOK_DIR}/gradebook-app/R

CMD ["shiny-server", "shiny.conf"]
