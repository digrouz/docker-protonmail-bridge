#!/usr/bin/env bash

. /etc/profile
. /usr/local/bin/docker-entrypoint-functions.sh

MYUSER="${APPUSER}"
MYUID="${APPUID}"
MYGID="${APPGID}"

AutoUpgrade

if [ "$1" == 'bridge' ]; then
  RunDropletEntrypoint
  DockLog "Starting app: ${1}"
  su-exec ${MYUSER} echo "exited"
else
  DockLog "Starting app: ${@}"
  exec "$@"
fi

