FROM php:8.1-fpm

ARG UID=1000
ARG GID=1000

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN apt update && apt install -y wget git unzip zip ca-certificates && update-ca-certificates

RUN chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions gd intl zip oauth opcache xdebug mysqli pdo_mysql imap decimal @composer @fix_letsencrypt
    # pgsql pdo_pgsql sockets yaml redis mcrypt

RUN usermod --uid $UID www-data && groupmod --gid $GID www-data

USER www-data:www-data
