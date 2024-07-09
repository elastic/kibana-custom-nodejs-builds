FROM centos:7

RUN sed -i s/mirror.centos.org/vault.centos.org/g /etc/yum.repos.d/*.repo \
    && sed -i s/^#.*baseurl=http/baseurl=http/g /etc/yum.repos.d/*.repo \
    && sed -i s/^mirrorlist=http/#mirrorlist=http/g /etc/yum.repos.d/*.repo

ARG GROUP_ID=1000
ARG USER_ID=1000

RUN groupadd --force --gid $GROUP_ID node
RUN adduser --gid $GROUP_ID --uid $USER_ID node

RUN ulimit -n 1024 \
    && yum install -y epel-release  \
    && yum install -y centos-release-scl \
    && yum-config-manager --enable centos-sclo-rh \
    && yum -y update --setopt=skip_if_unavailable=true \
    && yum clean all \
    && yum install -y \
        git \
        curl \
        make \
        python2 \
        python3 \
        ccache \
        xz-utils \
        devtoolset-9 \
        glibc-devel

RUN scl enable devtoolset-9 bash

COPY --chown=node:node entrypoint.sh /home/node/entrypoint.sh
COPY --chown=node:node re2_entrypoint.sh /home/node/re2_entrypoint.sh

USER node

VOLUME /home/node/workdir

ENTRYPOINT [ "/home/node/entrypoint.sh" ]
