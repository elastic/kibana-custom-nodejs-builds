FROM ubuntu:24.04

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

COPY --chown=ubuntu:ubuntu entrypoint.sh /home/node/entrypoint.sh

USER ubuntu

VOLUME /home/node/workdir

ENTRYPOINT [ "/home/node/entrypoint.sh" ]
