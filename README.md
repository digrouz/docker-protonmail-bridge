# docker-protonmail-bridge

[![auto-update](https://github.com/digrouz/docker-protonmail-bridge/actions/workflows/auto-update.yml/badge.svg)](https://github.com/digrouz/docker-protonmail-bridge/actions/workflows/auto-update.yml)
[![dockerhub](https://github.com/digrouz/docker-protonmail-bridge/actions/workflows/dockerhub.yml/badge.svg)](https://github.com/digrouz/docker-protonmail-bridge/actions/workflows/dockerhub.yml)
![Docker Pulls](https://img.shields.io/docker/pulls/digrouz/protonmail-bridge)

Installs ProtonMail Bridge into a Debian-based [s6-overlay](https://github.com/just-containers/s6-overlay) container.

![protonmail-bridge](https://res.cloudinary.com/dbulfrlrz/image/upload/v1693233221/static/logos/proton-mail-full-logo_fyuyou.svg)

## Tag

Several tag are available:

* latest: see debian
* debian: [Dockerfile_debian](https://github.com/digrouz/docker-protonmail-bridge/blob/master/Dockerfile_debian)

## Description

Proton Mail Bridge adds end-to-end encryption to popular email apps, including Outlook, Thunderbird, and Apple Mail. Secure email made easy

[Official Website](https://proton.me/mail/bridge)

> **Notice — you must add your Proton account once.**
>
> This image runs Bridge in **non-interactive** mode, so it can never prompt for
> your credentials on its own. You have to add your Proton Mail account **once,
> by hand** (see [Initialize your Proton account](#initialize-your-proton-account))
> before the bridge will sync anything. The setup lives under `/home/appuser`,
> so that path **must be on a persistent volume** or you will be asked to repeat
> the setup every time the container is recreated.

## Usage

    docker create --name=protonmail-bridge  \
      -e UID=<UID default:12345> \
      -e GID=<GID default:12345> \
      -e AUTOUPGRADE=<0|1 default:0> \
      -e TZ=<timezone default:Europe/Brussels> \
      -v protonmail-bridge:/home/appuser \
      -p 143:143 \
      -p 25:25 \
    digrouz/protonmail-bridge

    docker start protonmail-bridge

> **Note:** `-v ...:/home/appuser` mounts a persistent volume for the Bridge
> configuration, GPG key and `pass` store. Without it you lose your account on
> every container recreation and must re-run the
> [initialization](#initialize-your-proton-account).

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
* An helm chart is available of in the [chart folder](https://github.com/digrouz/docker-protonmail-bridge/tree/master/chart) with an example [values.yaml](https://github.com/digrouz/docker-protonmail-bridge/tree/master/chart/values.yaml)

## Initialize your Proton account

Bridge is started with `--noninteractive`, which means it will **not** ask for
your Proton Mail password at start-up. It instead re-uses the credentials you
entered during a one-time, interactive setup. Here is how the pieces fit
together.

### What happens automatically on first start

A one-shot service (`proton-bridge-init`) runs before the bridge and prepares
the environment (idempotently, on every start):

1. Ensures `/home/appuser` (the Bridge config directory) is owned by `appuser`.
2. Generates an **unencrypted** GPG key (`proton-key`).
3. Initializes the [pass](https://www.passwordstore.org/) password store with that
   key (`/home/appuser/.password-store`).
4. Runs `proton-bridge --cli init` to create the Bridge config/vault.

Because an unencrypted GPG key and a `pass` store exist, Bridge — which supports
`pass` as a Linux keychain — stores your account password GPG-encrypted inside
`/home/appuser/.password-store`. Since the key has **no passphrase**, the
`--noninteractive` service can unlock it automatically on every start, with no
prompting.

### Adding your account (one-time, interactive)

This is the only step you do by hand. It needs a TTY, so stop the non-interactive
service first, run the interactive CLI, then start the service again:

#### 1. Stop the bridge so it is not holding the config/vault

  docker exec protonmail-bridge s6-svc -d /var/run/s6/services/proton-bridge

#### 2. Run the interactive CLI and follow the prompts (add account -> Proton Mail address, password and 2FA code)
  
  docker exec -it protonmail-bridge \
      su-exec appuser /opt/protonmail/bin/proton-bridge --cli

#### 3. Start the bridge again
  
  docker exec protonmail-bridge s6-svc -u /var/run/s6/services/proton-bridge

> **Tip:** you can bring the bridge (and everything else) back up with
> `docker restart protonmail-bridge` instead of the `s6-svc -u` step.

#### Verify

    docker logs -f protonmail-bridge

You should see Bridge connect and start syncing. Your mail client can then use the
container's IP on **143** (IMAP) and **25** (SMTP).

#### Viewing the IMAP/SMTP credentials in the logs

On every start, a one-shot service (`proton-bridge-credentials`) runs after the
bridge is initialized and prints the IMAP/SMTP credentials for each configured
Proton account to the container logs, in a clearly labelled block:

    docker logs protonmail-bridge

The block shows, per account, the **username** (your Proton address) and the
**Bridge password** — the password your mail client authenticates with (it is
*not* your Proton login password, and it also works with your other Proton
addresses). It is only populated once you have added an account; on a fresh
volume the service instead prints a reminder to initialize your account first.

> **Note:** this intentionally writes your Bridge password to the container logs
> so you can configure a mail client without running anything interactively. If
> that is a concern for your environment, do not rely on the logs and retrieve
> the credentials another way (e.g. the interactive `info` command).

#### Changing the password / starting over

* To change the stored password, just repeat the interactive step above and edit
  the account.
* To start completely fresh, delete the `/home/appuser` volume and recreate the
  container; the automatic init will run again on next start.

## Issues

If you encounter an issue please open a ticket at [github](https://github.com/digrouz/docker-protonmail-bridge/issues)
