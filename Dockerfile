FROM php:7.4-apache

# Install tools required for build stage
RUN apt-get update \
 && apt-get install -fyqq \
    bash curl wget rsync ca-certificates openssl openssh-client git tzdata \
    libxrender1 fontconfig libc6 \
    gnupg binutils-gold autoconf \
    g++ gcc gnupg libgcc1 linux-headers-amd64 make python

# Install additional PHP libraries
RUN docker-php-ext-install \
    pcntl \
    bcmath \
    sockets

# Install mbstring plugin
RUN apt-get update \
 && apt-get install -fyqq libonig5 libonig-dev \
 && docker-php-ext-install mbstring \
 && apt-get remove -fyqq libonig-dev

# Install mysql plugin
RUN apt-get update \
 && apt-get install -fyqq mariadb-client libmariadbclient-dev \
 && docker-php-ext-install pdo_mysql mysqli \
 && apt-get remove -fyqq libmariadbclient-dev

# Install pgsql plugin
RUN apt-get update \
 && apt-get install -fyqq postgresql-client libpq-dev \
 && docker-php-ext-install pdo_pgsql pgsql \
 && apt-get remove -fyqq libpq-dev

# Install internalization plugin
RUN apt-get update \
 && apt-get install -fyqq libicu63 libicu-dev \
 && docker-php-ext-install intl \
 && apt-get remove -fyqq libicu-dev

# Install libraries for compiling GD, then build it
RUN apt-get update \
 && apt-get install -fyqq libfreetype6 libfreetype6-dev libpng16-16 libpng-dev libjpeg62-turbo libjpeg62-turbo-dev \
 && docker-php-ext-install gd \
 && apt-get remove -fyqq libfreetype6-dev libpng-dev libjpeg62-turbo-dev

# Add ZIP archives support (not needed here)
RUN apt-get update \
 && apt-get install -fyqq zip libzip-dev \
 && docker-php-ext-install zip \
 && apt-get remove -fyqq libzip-dev

# Install memcache
RUN apt-get update \
 && apt-get install -fyqq libmemcached11 libmemcached-dev \
 && pecl install memcached \
 && docker-php-ext-enable memcached \
 && apt-get remove -fyqq libmemcached-dev

# Install redis ext
RUN pecl install redis \
 && docker-php-ext-enable redis

# Install xdebug
RUN pecl install xdebug

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer \
 && chmod 755 /usr/bin/composer

# Add apache to run and configure
RUN a2enmod rewrite && a2enmod session && a2enmod session_cookie && a2enmod session_crypto && a2enmod deflate
ADD default.conf /etc/apache2/sites-available/000-default.conf

ADD ["entrypoint.sh", "/"]

RUN mkdir -pv /app \
 && chown -R www-data:www-data /app \
 && chmod -R 755 /app \
 && chmod +x /entrypoint.sh

WORKDIR /app

ENV LARAVEL_TAG="7.3.0"
ENV LARAVEL_TARGZ="https://api.github.com/repos/laravel/laravel/tarball"

RUN curl -L -o laravel.tar.gz "$LARAVEL_TARGZ/v$LARAVEL_TAG" \
 && tar xfvz laravel.tar.gz -C . --strip-components=1 \
 && chown www-data:www-data . -R \
 && rm laravel.tar.gz \
 && composer install --no-dev \
 && cp .env.example .env \
 && ./artisan key:generate

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["/entrypoint.sh"]
