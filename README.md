Welcome to PHPDOCKER
==================================
A preconfigured docker environment to your PHP projects

# Add your project #

Simply, clone this repo and and replace the entire contents of the `code/` directory with your code.

If you are starting a new symfony project run `make up` fllowed by `make sf-init v="<symfony-version>"` changing `<symfony-version>` for the version you want.

Ensure the webserver config on `phpdocker/nginx/nginx.conf` is correct for your project. PHPDocker customised this file according to the front controller location relative to the docker-compose file (by default `public/index.php`).

Note: the `override-php.ini` overrides and nginx config

# How to run #

Dependencies:

* docker. See [https://docs.docker.com/engine/installation](https://docs.docker.com/engine/installation)
* docker-compose. See [docs.docker.com/compose/install](https://docs.docker.com/compose/install/)

Once you're done, simply run `make up`. This will build and run all the containers in the background.

## Services exposed outside your environment ##

You can access your application via **`localhost`**. Mailhog and nginx both respond to any hostname, in case you want to
add your own hostname on your `/etc/hosts`

Service|Address outside containers
-------|--------------------------
Webserver|[localhost:8888](http://localhost:8888)
Mailhog web interface|[localhost:8025](http://localhost:8025)
Adminer (DB manager)|[localhost:8080](http://localhost:8080)
Ngrok (serve app to the internet)|[localhost:4040](http://localhost:4040)
MariaDB|**config:** see `.env` file

## Hosts within your environment ##

You'll need to configure your application to use any services you enabled:

Service|Hostname|Port number
------|---------|-----------
php-fpm|php-fpm|9000
MariaDB|database|3306 (default)
Redis|redis|6379 (default)
Elasticsearch|elasticsearch|9200 (HTTP default) / 9300 (ES transport default)
SMTP (Mailhog)|mailhog|1025 (default)

# Makefile cheatsheet #

You can run `make` command on console to see the make documentation

**Note:** you need to cd first to where Makefile lives


# Application file permissions #

As in all server environments, your application needs the correct file permissions to work properly. 
Before build the php-fpm service you need to change `USER_ID` and `GROUP_ID` on `.env` file to match with your user and group ids. 
You can figure out you user and group id by typing `id` on your console

This way you make sure that the `www-data` user within php-fpm container has the same id you have for your host user

# Recommendations #

It's hard to avoid file permission issues when fiddling about with containers due to the fact that, from your OS point
of view, any files created within the container are owned by the process that runs the docker engine (this is usually
root). Different OS will also have different problems, for instance you can run stuff in containers
using `docker exec -it -u $(id -u):$(id -g) CONTAINER_NAME COMMAND` to force your current user ID into the process, but
this will only work if your host OS is Linux, not mac. Follow a couple of simple rules and save yourself a world of
hurt.

* Run composer outside of the php container, as doing so would install all your dependencies owned by `root` within your
  vendor folder.
* Run commands (ie Symfony's console, or Laravel's artisan) straight inside of your container. You can easily open a
  shell as described above and do your thing from there.

# Simple basic Xdebug configuration with integration to PHPStorm

## Xdebug 2

To configure **Xdebug 2** you need add these lines in php-fpm/php-ini-overrides.ini:

### For linux:

```
xdebug.remote_enable = 1
xdebug.remote_connect_back = 1
xdebug.remote_autostart = 1
```

### For macOS and Windows:

```
xdebug.remote_enable = 1
xdebug.remote_host = host.docker.internal
xdebug.remote_autostart = 1
```

## Xdebug 3

To configure **Xdebug 3** you need add these lines in php-fpm/php-ini-overrides.ini:

### For linux:

```
xdebug.mode = debug
xdebug.remote_connect_back = true
xdebug.start_with_request = yes
```

### For macOS and Windows:

```
xdebug.mode = debug
xdebug.remote_host = host.docker.internal
xdebug.start_with_request = yes
```

## Add the section “environment” to the php-fpm service in docker-compose.yml:

```
environment:
  PHP_IDE_CONFIG: "serverName=Docker"
```

### Create a server configuration in PHPStorm:

* In PHPStorm open Preferences | Languages & Frameworks | PHP | Servers
* Add new server
* The “Name” field should be the same as the parameter “serverName” value in “environment” in docker-compose.yml (i.e. *
  Docker* in the example above)
* A value of the "port" field should be the same as first port(before a colon) in "webserver" service in
  docker-compose.yml
* Select "Use path mappings" and set mappings between a path to your project on a host system and the Docker container.
* Finally, add “Xdebug helper” extension in your browser, set breakpoints and start debugging



