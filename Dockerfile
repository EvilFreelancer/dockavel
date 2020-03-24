FROM evilfreelancer/alpine-apache-php7:latest

ENV LARAVEL_TAG="6.18.3"
ENV LARAVEL_TARGZ="https://api.github.com/repos/laravel/laravel/tarball"
WORKDIR /app

RUN curl -L -o laravel.tar.gz "$LARAVEL_TARGZ/v$LARAVEL_TAG" \
 && tar xfvz laravel.tar.gz -C . --strip-components=1 \
 && rm laravel.tar.gz \
 && composer install --no-dev
