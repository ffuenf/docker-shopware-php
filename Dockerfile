FROM php:7.3-apache

MAINTAINER Achim Rosenhagen <a.rosenhagen@ffuenf.de>

RUN apt-get update -qq && apt-get install -y -qq \
    build-essential \
    libicu-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libwebp-dev \
    libxpm-dev \
    libpng-dev \
    libcurl4-openssl-dev \
    software-properties-common \
    curl \
    git \
    libzip-dev \
    libzip4 \
    zip \
    unzip \
    inotify-tools \
    apt-utils \
    msmtp \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    git \
    default-mysql-client \
    sshpass \
    gnupg \
    nano \
    sudo \
    vim \
    rsync \
    jpegoptim \
    optipng

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-webp-dir=/usr/include/ \
    && docker-php-ext-install gd \
    && docker-php-ext-install opcache \
    && docker-php-ext-install zip \
    && docker-php-ext-install intl \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install soap \
    && docker-php-ext-install bcmath \
    && docker-php-ext-install sockets \
    && docker-php-ext-install calendar \
    && docker-php-ext-configure calendar

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

RUN echo "account mailcatcher\nhost localhost\nport 1025\nauto_from on\naccount default: mailcatcher" > /etc/msmtprc

COPY server-apache2-vhosts.conf /etc/apache2/sites-enabled/000-default.conf
ADD server-apache2-run-as.conf /etc/apache2/conf-available
RUN ln -s /etc/apache2/conf-available/server-apache2-run-as.conf /etc/apache2/conf-enabled

ADD php-config.ini /usr/local/etc/php/conf.d/php-config.ini
ADD timezone.ini /usr/local/etc/php/conf.d/timezone.ini

RUN a2enmod rewrite
RUN a2enmod ssl
RUN a2enmod headers
RUN a2enmod expires
RUN a2enmod negotiation
RUN a2enmod autoindex
RUN a2enmod deflate
RUN a2enmod alias

WORKDIR /var/www/html

COPY wait.sh /tmp/wait.sh
RUN chmod +x /tmp/wait.sh

COPY run-container.sh /run-container.sh
RUN chmod +x /run-container.sh

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php --install-dir=/usr/local/bin/ --filename=composer
RUN php -r "unlink('composer-setup.php');"

CMD /run-container.sh
