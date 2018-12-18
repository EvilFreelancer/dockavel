FROM evilfreelancer/alpine-apache-php7

ENV LARAVEL_TAG="5.7.19"
ENV LARAVEL_TARGZ="https://api.github.com/repos/laravel/laravel/tarball"
WORKDIR /app

RUN apk add --update --no-cache php7-fileinfo \
 && curl -L -o laravel.tar.gz "$LARAVEL_TARGZ/v$LARAVEL_TAG" \
 && tar xfvz laravel.tar.gz -C . --strip-components=1 \
 && rm laravel.tar.gz \
 && composer install --no-dev
