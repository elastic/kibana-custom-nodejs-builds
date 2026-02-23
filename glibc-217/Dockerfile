FROM centos:7

ARG GROUP_ID=1000
ARG USER_ID=1000
ARG PYTHON39_VERSION=3.9.21

RUN groupadd --force --gid $GROUP_ID node
RUN adduser --gid $GROUP_ID --uid $USER_ID node

RUN ulimit -n 1024 \
    && sed -i -e 's!mirrorlist!#mirrorlist!g' /etc/yum.repos.d/CentOS-* \
    && sed -i -e 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-* \
    && yum install -y epel-release \
    && yum install -y centos-release-scl-rh \
    && sed -i -e 's!mirrorlist!#mirrorlist!g' /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo \
    && if [ "$(uname -m)" == "x86_64" ]; then \
      sed -i -e 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo; \
    else \
      sed -i -e 's|#baseurl=http://mirror.centos.org/centos|baseurl=http://vault.centos.org/altarch|g' /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo; \
    fi \
    && yum upgrade -y \
    && yum install -y \
         git \
         curl \
         make \
         python2 \
         ccache \
         xz-utils \
         devtoolset-10 \
         glibc-devel \
         bzip2-devel \
         gdbm-devel \
         libffi-devel \
         ncurses-devel \
         openssl-devel \
         readline-devel \
         sqlite-devel \
         zlib-devel \
    && . /opt/rh/devtoolset-10/enable \
    && cd /tmp \
    && curl -fsSLO https://www.python.org/ftp/python/${PYTHON39_VERSION}/Python-${PYTHON39_VERSION}.tgz \
    && tar -xzf Python-${PYTHON39_VERSION}.tgz \
    && cd Python-${PYTHON39_VERSION} \
    && ./configure --prefix=/opt/python39 --with-ensurepip=install \
    && make -j"$(getconf _NPROCESSORS_ONLN)" \
    && make install \
    && /opt/python39/bin/python3.9 --version \
    && rm -rf /tmp/Python-${PYTHON39_VERSION} /tmp/Python-${PYTHON39_VERSION}.tgz \
    && yum clean all

ENV PATH="/opt/python39/bin:${PATH}"

COPY --chown=node:node entrypoint.sh /home/node/entrypoint.sh

USER node

VOLUME /home/node/workdir

ENTRYPOINT [ "/home/node/entrypoint.sh" ]
