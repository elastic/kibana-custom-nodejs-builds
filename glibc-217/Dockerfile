FROM centos:7

RUN sed -i -e "s|mirrorlist=|#mirrorlist=|g" /etc/yum.repos.d/CentOS-* \
    && sed -i -e "s|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g" /etc/yum.repos.d/CentOS-*

ARG GROUP_ID=1000
ARG USER_ID=1000

RUN groupadd --force --gid $GROUP_ID node
RUN adduser --gid $GROUP_ID --uid $USER_ID node

RUN ulimit -n 1024 \
    && yum install -y epel-release  \
    && yum install -y centos-release-scl-rh \
    && yum upgrade -y \
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

COPY --chown=node:node entrypoint.sh /home/node/entrypoint.sh
COPY --chown=node:node re2_entrypoint.sh /home/node/re2_entrypoint.sh

USER node

VOLUME /home/node/workdir

ENTRYPOINT [ "/home/node/entrypoint.sh" ]
