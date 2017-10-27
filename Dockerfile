FROM alpine:3.6

ARG RTORRENT_VERSION=0.9.6
ARG LIBTORRENT_VERSION=0.13.6

RUN addgroup -S rtorrent \
 && adduser -S -G rtorrent -s /bin/sh -h /var/lib/rtorrent rtorrent \
 && mkdir /var/lib/rtorrent/sessions \
 && mkdir /var/lib/rtorrent/watch \
 && mkdir /var/lib/rtorrent/downloads \
 && chown -R rtorrent: /var/lib/rtorrent \
 && apk add --no-cache --update \
        ncurses \
        libcurl \
        libstdc++ \
        libgcc \
 && apk add --no-cache --update --virtual .build-deps \
        git \
        autoconf \
        automake \
        libtool \
        cppunit-dev \
        make \
        g++ \
        ncurses-dev \
        curl-dev \
        zlib-dev \
        libressl-dev \
 && cd /tmp \
 && git clone https://github.com/mirror/xmlrpc-c.git \
 && cd xmlrpc-c/stable \
 && ./configure \
 && make -j $(getconf _NPROCESSORS_CONF) \
 && make install \
 && cd /tmp \
 && git clone -b ${LIBTORRENT_VERSION} https://github.com/rakshasa/libtorrent.git \
 && cd libtorrent \
 && ./autogen.sh \
 && ./configure \
 && make -j $(getconf _NPROCESSORS_CONF) \
 && make install \
 && cd /tmp \
 && git clone -b ${RTORRENT_VERSION} https://github.com/rakshasa/rtorrent.git \
 && cd rtorrent \
 && ./autogen.sh \
 && ./configure --with-xmlrpc-c \
 && make -j $(getconf _NPROCESSORS_CONF) \
 && make install \
 && rm -rf /tmp/* \
 && apk del .build-deps

COPY .rtorrent.rc /var/lib/rtorrent/

WORKDIR /var/lib/rtorrent

USER rtorrent

ENTRYPOINT [ "rtorrent" ]