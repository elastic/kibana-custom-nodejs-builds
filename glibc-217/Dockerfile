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

ENV GCC_VERSION=16.2.0
RUN cd /tmp \
    && curl -fsSLO https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.xz \
    && echo "e6738e29597f733270731aa90600f37ffdc045079dfc27ec7e8192cc81085c3e  gcc-${GCC_VERSION}.tar.xz" | sha256sum -c - \
    && tar xJf gcc-${GCC_VERSION}.tar.xz \
    && cd gcc-${GCC_VERSION} \
    && ./contrib/download_prerequisites \
    && mkdir build \
    && cd build \
    && . /opt/rh/devtoolset-10/enable \
    && ../configure \
        --prefix=/usr/local/gcc-16 \
        --enable-languages=c,c++ \
        --disable-multilib \
    && make -j$(nproc) \
    && make install \
    && cd /tmp \
    && rm -rf gcc-${GCC_VERSION} gcc-${GCC_VERSION}.tar.xz

ENV PYTHON_VERSION=3.15.2
RUN cd /tmp \
    && curl -fsSLO https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz \
    && echo "f74e1db0eabd651cd01e4e2a00201bd41866abe74869ab716f9bf33cbbaa0943  Python-${PYTHON_VERSION}.tgz" | sha256sum -c - \
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

# Node.js 26 needs Rust for Temporal. Pin the current stable release for both
# architectures and verify the publisher's archives before installing them.
ENV RUST_VERSION=1.99.1
RUN cd /tmp \
    && case "$(uname -m)" in \
         x86_64) rust_arch=x86_64; rust_sha=231fcae47ee950621374725b5fc3b5441d2fbda2955ac45dd7dc816d8876cfe7 ;; \
         aarch64) rust_arch=aarch64; rust_sha=a48fb1e853be56ce9b8e2751f5464dbd5e16440cd81e237920f3a5e7e806333e ;; \
         *) exit 1 ;; \
       esac \
    && rust_package="rust-${RUST_VERSION}-${rust_arch}-unknown-linux-gnu" \
    && curl -fsSLO "https://static.rust-lang.org/dist/${rust_package}.tar.xz" \
    && echo "${rust_sha}  ${rust_package}.tar.xz" | sha256sum -c - \
    && tar xJf "${rust_package}.tar.xz" \
    && "./${rust_package}/install.sh" --prefix=/opt/rust --disable-ldconfig \
         --components="rustc,cargo,rust-std-${rust_arch}-unknown-linux-gnu" \
    && rm -rf "${rust_package}" "${rust_package}.tar.xz"

ENV PATH="/opt/rust/bin:${PATH}"

COPY --chown=node:node entrypoint.sh /home/node/entrypoint.sh

USER node

VOLUME /home/node/workdir

ENTRYPOINT [ "/home/node/entrypoint.sh" ]
