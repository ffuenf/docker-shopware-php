FROM php:7.2-apache

MAINTAINER Achim Rosenhagen <a.rosenhagen@ffuenf.de>

RUN apt-get update -qq && apt-get install -y -qq \
    build-essential \
    libicu-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libcurl4-openssl-dev \
    software-properties-common \
    libcurl3 curl \
    git \
    zip \
    unzip \
    inotify-tools \
    apt-utils \
    ssmtp \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    git \
    mysql-client \
    sshpass \
    gnupg \
    nano \
    sudo \
    vim \
    rsync \
    jpegoptim \
    optipng

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \
    && docker-php-ext-install opcache \
    && docker-php-ext-install zip \
    && docker-php-ext-install intl \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install soap \
    && docker-php-ext-install bcmath \
    && docker-php-ext-install sockets

RUN pecl install apcu
RUN echo "extension=apcu.so" > /usr/local/etc/php/conf.d/apcu.ini

RUN pecl install redis \
    && docker-php-ext-enable redis

RUN apt-get update && apt-get install -y -qq \
    git libmagick++-dev \
    --no-install-recommends && rm -r /var/lib/apt/lists/* && \
    git clone https://github.com/mkoppanen/imagick.git && \
    cd imagick && phpize && ./configure && \
    make && make install && \
    docker-php-ext-enable imagick && \
    cd ../ && rm -rf imagick

RUN echo "mailhub=mailcatcher:1025\nUseTLS=NO\nFromLineOverride=YES" > /etc/ssmtp/ssmtp.conf

COPY server-apache2-vhosts.conf /etc/apache2/sites-enabled/000-default.conf
ADD server-apache2-run-as.conf /etc/apache2/conf-available
RUN ln -s /etc/apache2/conf-available/server-apache2-run-as.conf /etc/apache2/conf-enabled

ADD php-config.ini /usr/local/etc/php/conf.d/php-config.ini
ADD timezone.ini /usr/local/etc/php/conf.d/timezone.ini

RUN a2enmod rewrite
RUN a2enmod ssl

WORKDIR /var/www/html

COPY wait.sh /tmp/wait.sh
RUN chmod +x /tmp/wait.sh

COPY run-container.sh /run-container.sh
RUN chmod +x /run-container.sh

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php --install-dir=/usr/local/bin/ --filename=composer
RUN php -r "unlink('composer-setup.php');"

CMD /run-container.sh
