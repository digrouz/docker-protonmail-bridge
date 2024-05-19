[![auto-update](https://github.com/digrouz/docker-protonmail-bridge/actions/workflows/auto-update.yml/badge.svg)](https://github.com/digrouz/docker-protonmail-bridge/actions/workflows/auto-update.yml)
[![dockerhub](https://github.com/digrouz/docker-protonmail-bridge/actions/workflows/dockerhub.yml/badge.svg)](https://github.com/digrouz/docker-protonmail-bridge/actions/workflows/dockerhub.yml)
![Docker Pulls](https://img.shields.io/docker/pulls/digrouz/protonmail-bridge)

# docker-protonmail-bridge
Installs ProtonMail Bridge into an Alpine container.

![protonmail-bridge](https://res.cloudinary.com/dbulfrlrz/image/upload/v1693233221/static/logos/proton-mail-full-logo_fyuyou.svg)

## Tag
Several tag are available:
* latest: see debian
* debian: [Dockerfile_debian](https://github.com/digrouz/docker-protonmail-bridge/blob/master/Dockerfile_debian)


## Description

Proton Mail Bridge adds end-to-end encryption to popular email apps, including Outlook, Thunderbird, and Apple Mail. Secure email made easy

https://proton.me/mail/bridge

## Usage
    docker create --name=protonmail-bridge  \
      -e UID=<UID default:12345> \
      -e GID=<GID default:12345> \
      -e AUTOUPGRADE=<0|1 default:0> \
      -e TZ=<timezone default:Europe/Brussels> \
      -p 143:143 \
      -p 25:25 \
    digrouz/protonmail-bridge

## Environment Variables

When you start the `protonmail-bridge` image, you can adjust the configuration of the `protonmail-bridge` instance by passing one or more environment variables on the `docker run` command line.

### `UID`

This variable is not mandatory and specifies the user id that will be set to run the application. It has default value `12345`.

### `GID`

This variable is not mandatory and specifies the group id that will be set to run the application. It has default value `12345`.

### `AUTOUPGRADE`

This variable is not mandatory and specifies if the container has to launch software update at startup or not. Valid values are `0` and `1`. It has default value `0`.

### `TZ`

This variable is not mandatory and specifies the timezone to be configured within the container. It has default value `Europe/Brussels`.

## Notes

* This container is built using [s6-overlay](https://github.com/just-containers/s6-overlay)
* The docker entrypoint can upgrade operating system at each startup. To enable this feature, just add `-e AUTOUPGRADE=1` at container creation.

## Issues

If you encounter an issue please open a ticket at [github](https://github.com/digrouz/docker-protonmail-bridge/issues)
