FROM openeuler/openeuler:22.03-lts as bootstrap

ARG TARGETARCH
ARG SP_VERSION

RUN echo "I'm building kylin-V10SP${SP_VERSION} for arch ${TARGETARCH}"
RUN rm -rf /target && mkdir -p /target/etc/yum.repos.d && mkdir -p /etc/pki/rpm-gpg
COPY kylin-V10SP${SP_VERSION}.repo /target/etc/yum.repos.d/kylin.repo
COPY RPM-GPG-KEY-kylin /target/etc/pki/rpm-gpg/RPM-GPG-KEY-kylin
COPY RPM-GPG-KEY-kylin /etc/pki/rpm-gpg/RPM-GPG-KEY-kylin

# see https://github.com/BretFisher/multi-platform-docker-build
# make the yum repo file with correct filename; eg: kylin_x86_64.repo
RUN case ${TARGETARCH} in \
         "amd64")  ARCHNAME=x86_64  ;; \
         "arm64")  ARCHNAME=aarch64  ;; \
    esac && \
    mv /target/etc/yum.repos.d/kylin.repo /target/etc/yum.repos.d/kylin_${ARCHNAME}.repo

RUN set -eux; \
    dnf update -y \
    yum --installroot=/target \
    --releasever=10 \
    --setopt=tsflags=nodocs \
    install -y kylin-release coreutils rpm yum bash procps tar shadow-utils

FROM scratch as runner
COPY --from=bootstrap /target /
RUN yum --releasever=10 \
    --setopt=tsflags=nodocs \
    install -y kylin-release coreutils rpm yum bash procps tar shadow-utils

RUN yum clean all && \
    rm -rf /var/cache/yum && \
    rm -rf /var/log/*

RUN cp /usr/lib/locale/locale-archive /usr/lib/locale/locale-archive.tmpl && \
    build-locale-archive --install-langs="en:zh"

FROM scratch
COPY --from=runner / /
CMD /bin/bash