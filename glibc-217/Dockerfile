FROM centos:7

ARG GROUP_ID=1000
ARG USER_ID=1000

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
         xz \
         devtoolset-10 \
         glibc-devel \
         # Python 3.9 build dependencies
         openssl-devel \
         bzip2-devel \
         libffi-devel \
         zlib-devel

RUN cd /tmp \
    && curl -O https://www.python.org/ftp/python/3.9.25/Python-3.9.25.tgz \
    && echo "a7438eabd3a48139f42d4e058096af8d880b0bb6e8fb8c78838892e4ce5583f2  Python-3.9.25.tgz" | sha256sum -c - \
    && tar xzf Python-3.9.25.tgz \
    && cd Python-3.9.25 \
    && . /opt/rh/devtoolset-10/enable \
    && ./configure --enable-optimizations --prefix=/usr/local \
    && make -j$(nproc) \
    && make altinstall \
    && cd /tmp \
    && rm -rf Python-3.9.25* \
    && ln -s /usr/local/bin/python3.9 /usr/local/bin/python3 \
    && ln -s /usr/local/bin/pip3.9 /usr/local/bin/pip3

COPY --chown=node:node entrypoint.sh /home/node/entrypoint.sh

USER node

VOLUME /home/node/workdir

ENTRYPOINT [ "/home/node/entrypoint.sh" ]
