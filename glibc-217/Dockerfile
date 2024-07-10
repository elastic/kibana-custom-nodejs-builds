FROM centos:7

RUN echo "[centos-sclo-rh]" > /etc/yum.repos.d/centos-release-scl-rh.repo \
    && echo "name=CentOS-7 - SCLo rh" >> /etc/yum.repos.d/centos-release-scl-rh.repo \
    && echo "baseurl=http://vault.centos.org/centos/7/sclo/\$basearch/rh/" >> /etc/yum.repos.d/centos-release-scl-rh.repo \
    && echo "gpgcheck=1" >> /etc/yum.repos.d/centos-release-scl-rh.repo \
    && echo "gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-SCLo" >> /etc/yum.repos.d/centos-release-scl-rh.repo

RUN sed -i -e "s|mirrorlist=|#mirrorlist=|g" /etc/yum.repos.d/CentOS-* \
    && sed -i -e "s|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g" /etc/yum.repos.d/CentOS-*

RUN cat /etc/yum.repos.d/*.repo
RUN cat /etc/yum.repos.d/centos-release-scl-rh.repo

ARG GROUP_ID=1000
ARG USER_ID=1000

RUN groupadd --force --gid $GROUP_ID node
RUN adduser --gid $GROUP_ID --uid $USER_ID node

RUN ulimit -n 1024 \
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
