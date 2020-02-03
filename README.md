# Dockavel = Docker + Laravel

Simple image with basic Laravel inside Docker container, based on
Alpine Linux with latest PHP (whick availble on stable Alpine of
course).

Repository has different versions of Laravel (from 5.4), so if you need
some legacy version of Laravel the you need set [required tag](https://hub.docker.com/r/evilfreelancer/dockavel/tags/).

## How to use

### How to enable xdebug

This PHP plugin is already installed into container and can be enabled
via PHP_XDEBUG_ENABLED environment variable.

All available environment variables of PHP can be found
[here](https://github.com/EvilFreelancer/alpine-apache-php7).

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

  laravel-dev:
    image: evilfreelancer/dockavel
    restart: unless-stopped
    ports:
      - 81:80
    environment:
      - APP_NAME=Develop
      - APP_ENV=local
      - APP_DEBUG=true
      - PHP_XDEBUG_ENABLED=true
    volumes:
      - ./laravel:/app:rw

  laravel:
    image: evilfreelancer/dockavel
    restart: unless-stopped
    ports:
      - 80:80
    environment:
      - APP_NAME=Laravel
      - APP_ENV=stagging
      - APP_KEY=base64:XFmYKmOH9JhC4egs5y7h9hKnACECuRpVvybd8gaU1EA=
      - APP_DEBUG=false
      - APP_URL=http://localhost
      - LOG_CHANNEL=stack
      - DB_CONNECTION=mysql
      - DB_HOST=mysql
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
    volumes:
      - ./laravel/app:/app/app:rw
      - ./laravel/config:/app/config:rw
      - ./laravel/database:/app/database:rw
      - ./laravel/public:/app/public:rw
      - ./laravel/resources:/app/resources:rw
      - ./laravel/routes:/app/routes:rw
      # Required modules for system
      - ./laravel/vendor:/app/vendor:rw
      - ./laravel/node_modules:/app/node_modules:rw
      # Following folders must be writable in container for apache user
      # chown apache:apache -R storage/ bootstrap/
      - ./laravel/storage:/app/storage:rw
      - ./laravel/bootstrap:/app/bootstrap:rw
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
