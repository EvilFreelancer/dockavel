# Dockavel = Docker + Laravel

Simple image with basic Laravel inside Docker container, based on
Alpine Linux with latest PHP (whick availble on stable Alpine of
course).

Repository has different versions of Laravel (from 5.4), so if you need
some legacy version of Laravel the you need set [required tag](https://hub.docker.com/r/evilfreelancer/dockavel/tags/).

## How to use

### Via Dockerfile

If you want to use this image and you just need to add source code of
yor application with dependencies, for this just create `Dockerfile`
with following content inside:

```docker
FROM evilfreelancer/dockavel

ADD [".", "/app/app"]
ADD ["composer.json", "/app/app"]
WORKDIR /app

RUN composer update \
 && chown -R apache:apache /app
```

For building you just need run:

    docker build . --tag laravel

By default image [alpine-apache-php7](https://hub.docker.com/r/evilfreelancer/alpine-apache-php7/)
has `80` port exposed (apache2 here), so you just need plug your local
port with port of container together:

    docker run -d -p 80:80 laravel

### Via docker-compose

If you need MySQL with Laravel the you need create the
`docker-compose.yml` file and put inside following content:

```yml
version: "2"

services:

  mysql:
    image: mysql:5.7
    ports:
      - 3306:3306
    environment:
      # Configuration here must match the settings of laravel
      - MYSQL_DATABASE=homestead
      - MYSQL_ROOT_PASSWORD=root_pass
      - MYSQL_USER=homestead
      - MYSQL_PASSWORD=secret
    volumes:
      - ./databases/mysql:/var/lib/mysql
      - ./logs/mysql:/var/log/mysql

  laravel:
    image: evilfreelancer/dockavel
    restart: unless-stopped
    ports:
      - 80:80
    environment:
      # List of all default environmets of Laravel
      - APP_NAME=Laravel
      - APP_ENV=local
      - APP_KEY=
      - APP_DEBUG=true
      - APP_URL=http://localhost
      - LOG_CHANNEL=stack
      - DB_CONNECTION=mysql
      - DB_HOST=127.0.0.1
      - DB_PORT=3306
      - DB_DATABASE=homestead
      - DB_USERNAME=homestead
      - DB_PASSWORD=secret
      - BROADCAST_DRIVER=log
      - CACHE_DRIVER=file
      - SESSION_DRIVER=file
      - SESSION_LIFETIME=120
      - QUEUE_DRIVER=sync
      - REDIS_HOST=127.0.0.1
      - REDIS_PASSWORD=null
      - REDIS_PORT=6379
      - MAIL_DRIVER=smtp
      - MAIL_HOST=smtp.mailtrap.io
      - MAIL_PORT=2525
      - MAIL_USERNAME=null
      - MAIL_PASSWORD=null
      - MAIL_ENCRYPTION=null
      - PUSHER_APP_ID=
      - PUSHER_APP_KEY=
      - PUSHER_APP_SECRET=
      - PUSHER_APP_CLUSTER=mt1
      - MIX_PUSHER_APP_KEY="${PUSHER_APP_KEY}"
      - MIX_PUSHER_APP_CLUSTER="${PUSHER_APP_CLUSTER}"
      # Settings of php.ini
      - PHP_SHORT_OPEN_TAG=On
      - PHP_ERROR_REPORTING=E_ALL
      - PHP_DISPLAY_ERRORS=On
      - PHP_HTML_ERRORS=On
      - PHP_XDEBUG_ENABLED=true
    volumes:
      # You need mont `application` folder to the `app` inside container
      - ./app:/app/app
      # inside this folder storred the deps downloaded by composer
      - ./vendor:/app/vedonr
```

Run this composition of containers:

    docker-compuse up -d

But how to update the Laravel image? That's easy, if you use `:latest`
tag of docker image the you just need:

    docker-composer pull
    docker-composer up -d

And your of laravel container will be recreated if new version of
Laravel in repository.

## Almost done

Now you need just open this url http://localhost, and you'll see the Laravel magic.

## Links

* [alpine-apache-php7](https://hub.docker.com/r/evilfreelancer/alpine-apache-php7/)
* [Laradock](http://laradock.io/)
