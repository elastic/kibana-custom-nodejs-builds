FROM centos:7

RUN sed -i -e "s|mirrorlist=|#mirrorlist=|g" /etc/yum.repos.d/CentOS-*
RUN if [ "$(uname -m)" == "x86_64" ]; then \
      echo "Running on x64 architecture"; \
      sed -i -e 's!#baseurl=http://mirror.centos.org/centos/\$releasever!baseurl=https://vault.centos.org/7.9.2009/!g' /etc/yum.repos.d/CentOS-Base.repo; \
    else \
      echo "Running on non-x64 architecture"; \
      sed -i 's|#baseurl=http://mirror.centos.org/altarch/\$releasever/|baseurl=http://vault.centos.org/altarch/7.9.2009/|' /etc/yum.repos.d/CentOS-Base.repo; \
    fi
RUN sed -i -e "s|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g" /etc/yum.repos.d/CentOS-*

RUN cat /etc/yum.repos.d/*.repo

ARG GROUP_ID=1000
ARG USER_ID=1000

RUN groupadd --force --gid $GROUP_ID node
RUN adduser --gid $GROUP_ID --uid $USER_ID node

RUN ulimit -n 1024 \
    && yum update -y \
    && yum clean all \
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
