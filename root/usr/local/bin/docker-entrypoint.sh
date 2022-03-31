#!/usr/bin/env bash

. /etc/profile
. /usr/local/bin/docker-entrypoint-functions.sh

MYUSER="${APPUSER}"
MYUID="${APPUID}"
MYGID="${APPGID}"

AutoUpgrade

if [ "$1" == 'bridge-init' ]; then
    gpg --generate-key --batch /opt/protonmail/etc/gpg-parameters
    pass init proton-key
    /opt/protonmail/bin/proton-bridge --cli $@
elif [ "$1" == 'bridge' ]; then
  RunDropletEntrypoint
  DockLog "Bind smtp port 25"
  socat TCP-LISTEN:25,fork TCP:127.0.0.1:1025 &
  DockLog "Bind imap port 143"
  socat TCP-LISTEN:143,fork TCP:127.0.0.1:1143 &
  DockLog "Starting app: ${1}"
  su-exec ${MYUSER} /opt/protonmail/bin/proton-bridge --cli $@
else
  DockLog "Starting app: ${@}"
  exec "$@"
fi

