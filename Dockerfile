FROM rocker/rstudio

ARG DEBIAN_FRONTEND=noninteractive

# Actualizar apt e instalar wget y git
RUN apt -y -qq update \
  && apt -y -qq --no-install-recommends install \
     sudo wget git ca-certificates vim


# Instalar DSSAT
RUN apt -y -qq --no-install-recommends install make cmake gfortran
RUN wget --output-document=/tmp/install-dssat \
    https://raw.githubusercontent.com/danielbonhaure/dssat-installation/master/install-dssat
ARG DFOLDER="/opt/dssat"
ARG RGITHUB="https://github.com/alessiobocco/dssat-csm-os"
ARG BGITHUB="develop"
ARG DEXTABL="dscsm047"
ARG DVRSION="47"
RUN export TERM=xterm && chmod a+x /tmp/install-dssat \
  && /tmp/install-dssat -f ${DFOLDER} -r ${RGITHUB} -b ${BGITHUB} -d


# Instalar paquetes R necesarios
RUN apt -y -qq --no-install-recommends install \
  && R -e "options(warn=2); install.packages('here', verbose=T, quiet=T, keep_outputs='/tmp/')" \
  && R -e "options(warn=2); install.packages('fs', verbose=T, quiet=T, keep_outputs='/tmp/')" \
  && R -e "options(warn=2); install.packages('lubridate', verbose=T, quiet=T, keep_outputs='/tmp/')" \
  && R -e "options(warn=2); install.packages('forcats', verbose=T, quiet=T, keep_outputs='/tmp/')" \
  && R -e "options(warn=2); install.packages('future', verbose=T, quiet=T, keep_outputs='/tmp/')" \
  && R -e "options(warn=2); install.packages('rlang', verbose=T, quiet=T, keep_outputs='/tmp/')" \
  && R -e "options(warn=2); install.packages('glue', verbose=T, quiet=T, keep_outputs='/tmp/')" \
  && R -e "options(warn=2); install.packages('stringr', verbose=T, quiet=T, keep_outputs='/tmp/')" \
  && R -e "options(warn=2); install.packages('dplyr', verbose=T, quiet=T, keep_outputs='/tmp/')" \
  && R -e "options(warn=2); install.packages('purrr', verbose=T, quiet=T, keep_outputs='/tmp/')" \
  && R -e "options(warn=2); install.packages('magrittr', verbose=T, quiet=T, keep_outputs='/tmp/')" \
  && R -e "options(warn=2); install.packages('tidyr', verbose=T, quiet=T, keep_outputs='/tmp/')" \
  && R -e "options(warn=2); install.packages('raster', verbose=T, quiet=T, keep_outputs='/tmp/')" \
  && R -e "options(warn=2); install.packages('terra', verbose=T, quiet=T, keep_outputs='/tmp/')" \
  && R -e "options(warn=2); install.packages('missForest', verbose=T, quiet=T, keep_outputs='/tmp/')" \
  && R -e "options(warn=2); install.packages('missMDA', verbose=T, quiet=T, keep_outputs='/tmp/')" \
  && R -e "options(warn=2); install.packages('mgcv', verbose=T, quiet=T, keep_outputs='/tmp/')" \
  && R -e "options(warn=2); install.packages('sp', verbose=T, quiet=T, keep_outputs='/tmp/')" \
  && R -e "options(warn=2); install.packages('sf', verbose=T, quiet=T, keep_outputs='/tmp/')" \
  && R -e "options(warn=2); install.packages('sirad', verbose=T, quiet=T, keep_outputs='/tmp/')" \
  && R -e "options(warn=2); install.packages('elevatr', verbose=T, quiet=T, keep_outputs='/tmp/')" \
  && R -e "options(warn=2); install.packages('feather', verbose=T, quiet=T, keep_outputs='/tmp/')" \
  && R -e "options(warn=2); install.packages('RandomFields', verbose=T, quiet=T, keep_outputs='/tmp/')" \
  && R -e "options(warn=2); install.packages('DSSAT', verbose=T, quiet=T, keep_outputs='/tmp/')" 


# Cambiar UID y GID para poder leer y editar archivos
ARG USER_UID="1000"
ARG USER_GID="1000"
RUN usermod -u $USER_UID rstudio
RUN find / -ignore_readdir_race -user 1000 -exec chown -h rstudio {} \;
RUN groupmod -g $USER_GID rstudio
RUN find / -ignore_readdir_race -group 1000 -exec chgrp -h rstudio {} \;


# Llamar al init de rstudio
CMD ["/init"]

#
# 1- docker build --tag dssat:rstudio --force-rm \
#                 --build-arg USER_UID=$(stat -c "%u" .) \
#                 --build-arg USER_GID=$(stat -c "%g" .) \
#                 --file Dockerfile .
#
# 2- docker run --name rstudio --rm --detach \
#               -p 8888:8787 \
#               -v $(pwd)/:/home/rstudio/ \
#               -e ROOT=TRUE \
#               -e PASSWORD=<contraseña> \
#               dssat:rstudio
#


