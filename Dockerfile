FROM php:7.4-fpm

MAINTAINER Achim Rosenhagen <a.rosenhagen@ffuenf.de>

ADD https://raw.githubusercontent.com/mlocati/docker-php-extension-installer/master/install-php-extensions /usr/local/bin/

RUN chmod uga+x /usr/local/bin/install-php-extensions && \
    sync && \
    install-php-extensions \
    dom \
    fileinfo \
    gd \
    iconv \
    intl \
    json \
    libxml \
    mbstring \
    openssl \
    pcre \
    pdo \
    pdo_mysql \
    phar \
    simplexml \
    xml \
    zip \
    zlib \
    apcu \
    opcache \
    sockets
