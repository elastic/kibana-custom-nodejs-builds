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
         glibc-devel \
         # gcc build dependencies
         devtoolset-10 \
         wget \
         bzip2 \
         # Python build dependencies
         openssl-devel \
         bzip2-devel \
         libffi-devel \
         zlib-devel

ENV GCC_VERSION=13.5.0
RUN cd /tmp \
    && curl -O https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.gz \
    && echo "ee0c6280fb2e18304cb447a1abb5ed479c74196c75e01cde634489b80bcd172b  gcc-${GCC_VERSION}.tar.gz" | sha256sum -c - \
    && tar xzf gcc-${GCC_VERSION}.tar.gz \
    && cd gcc-${GCC_VERSION} \
    && ./contrib/download_prerequisites \
    && mkdir build \
    && cd build \
    && . /opt/rh/devtoolset-10/enable \
    && ../configure \
        --prefix=/usr/local/gcc-13 \
        --enable-languages=c,c++ \
        --disable-multilib \
    && make -j$(nproc) \
    && make install \
    && cd /tmp \
    && rm -rf gcc-${GCC_VERSION} gcc-${GCC_VERSION}.tar.gz

ENV PYTHON_VERSION=3.12.16
RUN cd /tmp \
    && curl -O https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz \
    && echo "710c3e75dac8b2f258d9cd0f76e5c4c2e9175fac9e249c98901552f7cf33b7dd  Python-${PYTHON_VERSION}.tgz" | sha256sum -c - \
    && tar xzf Python-${PYTHON_VERSION}.tgz \
    && cd Python-${PYTHON_VERSION} \
    && . /opt/rh/devtoolset-10/enable \
    && ./configure --enable-optimizations --prefix=/usr/local \
    && make -j$(nproc) \
    && make altinstall \
    && cd /tmp \
    && rm -rf Python-${PYTHON_VERSION}* \
    && ln -s /usr/local/bin/python${PYTHON_VERSION%.*} /usr/local/bin/python3 \
    && ln -s /usr/local/bin/pip${PYTHON_VERSION%.*} /usr/local/bin/pip3

COPY --chown=node:node entrypoint.sh /home/node/entrypoint.sh

USER node

VOLUME /home/node/workdir

ENTRYPOINT [ "/home/node/entrypoint.sh" ]
