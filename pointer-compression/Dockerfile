FROM ubuntu:24.04

ARG GID=1000
ARG UID=1000

RUN apt-get update \
    && apt-get dist-upgrade -y \
    && apt-get install -y software-properties-common \
    && add-apt-repository -y ppa:ubuntu-toolchain-r/test \
    && apt-get update \
    && apt-get install -y \
         git \
         g++ \
         curl \
         make \
         python3 \
         python3-pip \
         python3-setuptools \
         ccache \
         xz-utils

RUN addgroup --gid $GID node \
    && adduser --gid $GID --uid $UID --disabled-password --gecos node node

COPY --chown=node:node entrypoint.sh /home/node/entrypoint.sh

USER node

VOLUME /home/node/workdir

ENTRYPOINT [ "/home/node/entrypoint.sh" ]
