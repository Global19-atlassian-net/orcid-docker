# Deploy ORCID with DOCKER

This project uses docker containers to startup JavaEE PostgreSQL [web application](https://qa.orcid.org/). The local environment will be available at [localhost](https://localhost:8443/)

## Install docker community edition

Follow install instructions at https://docs.docker.com/install/

* [Get Docker for Mac](https://download.docker.com/mac/stable/Docker.dmg)
* [Get Docker for Windows](https://download.docker.com/win/stable/Docker%20for%20Windows%20Installer.exe)
* [Get Docker for Linux](https://download.docker.com/linux/static/stable/aarch64/docker-18.03.1-ce.tgz)

## Install docker compose 
Follow instructions for [installing docker-compose on macOS, Windows, and 64-bit Linux ](https://docs.docker.com/compose/install/)

## Environment variables

|   Env Var     |       Description              |
|---------------|--------------------------------|
| ORCID_SOURCE  | /Users/jperez/git/ORCID_Source |
| PG_PASSWORD   | orcid                          |

> Adjust test.env and save it as .env

## Startup orcid-web with docker compose

### Download this container wrapper

    git clone https://github.com/ORCID/orcid-docker.git
    cd orcid-docker

### Prepare orcid-web java web application

Build and pack the orcid web war file, helper script and config at

    cp ./tomcat/test.env .env
    sh ./tomcat/package_orcid_web.sh master

### Run

To start all services from the root folder do

    docker-compose up -d

> We can found containers IP from container name with `docker inspect --format '{{ (index .NetworkSettings.Networks "orcid_default").IPAddress }}' orcid_web_1`

and.. That's it.

### Test web app

Test the service with

    curl -I -k -L https://localhost:8443/orcid-web/signin

or simply browse to https://localhost:8443/orcid-web

### Shutdown your local environment

Later we can stop or destroy the environment with

    docker-compose stop
    docker-compose down

## Manual build of containers (Optional)

#### Setup ORCID database

Reusing [postgres library](https://docs.docker.com/samples/library/postgres/), create local volume to persist orcid data

    docker volume create orcid_data
    docker run --name orcid-postgres \
    -v $(pwd)/tomcat/initdb:/docker-entrypoint-initdb.d \
    -v orcid_data:/var/lib/postgresql/9.5/main \
    -d postgres:9.5

> Every sql files at /tomcat/initdb/* is going to be run as `psql -U postgres -f /opt/initdb/orcid_dump.sql`, Download orcid_dump.sql from any sandbox machine

#### Create orcid-web source ready container

Build the base java web container

    cd ~/git/ORCID-Source
    mvn clean install package -Dmaven.test.skip=true -Dlicense.skip=true

Ready to build our custom orcid-web container

    cd ~/git/orcid-docker/tomcat
    docker build --rm -t orcid/web -f ./tomcat/Dockerfile .

If new container is available at `docker images` then we're ready to run orcid-web

    docker run --name orcid-web \
    --rm -v `pwd`/orcid:/orcid \
    --link orcid-postgres:dev-db.orcid.org \
    -d orcid/web

watch the app startup with

    docker logs -f orcid-web
