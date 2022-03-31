#!/usr/bin/env bash

BRIDGE_URL="https://api.github.com/repos/ProtonMail/proton-bridge/tags"

FULL_LAST_VERSION=$(curl -SsL ${BRIDGE_URL} | \
              jq -r -c '.[] | \
                        select( .name | \
                                (contains("rc") | not) and \
                                (contains("beta") | not) and \
                                (contains("alpha") | not) \
                              ) | \
                        .name' |\
              head -1 \
              )
LAST_VERSION="${FULL_LAST_VERSION:1}"

sed -i -e "s|BRIDGE_VERSION='.*'|BRIDGE_VERSION='${LAST_VERSION}'|" Dockerfile*

if output=$(git status --porcelain) && [ -z "$output" ]; then
  # Working directory clean
  echo "No new version available!"
else 
  # Uncommitted changes
  git commit -a -m "update to version: ${LAST_VERSION}"
  git push
fi
