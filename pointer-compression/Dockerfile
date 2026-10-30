FROM ubuntu:24.04

ARG GID=1000
ARG UID=1000

RUN apt-get update \
    && apt-get dist-upgrade -y \
    && apt-get install -y --no-install-recommends \
         adduser \
         git \
         g++ \
         curl \
         make \
         python3 \
         python3-pip \
         python3-setuptools \
         ccache \
         xz-utils \
    && rm -rf /var/lib/apt/lists/*

RUN deluser --remove-home ubuntu \
    && addgroup --gid $GID node \
    && adduser --gid $GID --uid $UID --disabled-password --gecos node node

# Without Rust, a Node.js 26 build silently omits Temporal.
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
