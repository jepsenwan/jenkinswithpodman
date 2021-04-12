# runc
FROM golang:1.14-alpine3.12 AS runc
ARG RUNC_VERSION=v1.0.0-rc92
RUN set -eux; \
	apk add --no-cache --virtual .build-deps gcc musl-dev libseccomp-dev make git bash; \
	git clone --branch ${RUNC_VERSION} https://github.com/opencontainers/runc src/github.com/opencontainers/runc; \
	cd src/github.com/opencontainers/runc; \
	make static BUILDTAGS='seccomp selinux ambient'; \
	mv runc /usr/local/bin/runc; \
	rm -rf $GOPATH/src/github.com/opencontainers/runc; \
	apk del --purge .build-deps; \
	[ "$(ldd /usr/local/bin/runc | wc -l)" -eq 0 ] || (ldd /usr/local/bin/runc; false)

FROM ubuntu:18.04

COPY go1.16.3.linux-amd64.tar.gz ./

ENV GOPATH=/root/go

#Install Go
RUN rm -rf /usr/local/go && tar -C /usr/local -xzf go1.16.3.linux-amd64.tar.gz && apt-get -y update && apt-get -y install make gcc

RUN apt-get -y install libgpgme-dev libseccomp-dev && apt-get -y install git &&  apt-get -y install pkg-config && apt-get -y install libglib2.0-dev


RUN git clone https://github.com/containers/conmon && cd /conmon && make && make podman && cp /usr/local/libexec/podman/conmon  /usr/local/bin/

#path env
ENV PATH=$PATH:/usr/local/go/bin/

COPY --from=runc   /usr/local/bin/runc   /usr/local/bin/runc

#cp podman source code
COPY containers/. /root/go/src/github.com/containers
COPY varlink/. /root/go/src/github.com/varlink

RUN ls /root/go/src/github.com/varlink

RUN cd /root/go/src/github.com/containers/libpod && make && make install 
