#!/usr/bin/env bash

GOLANG_URL="https://api.github.com/repos/golang/go/tags?page=4"

FULL_LAST_VERSION=$(curl -SsL -H "Accept: application/vnd.github.v3+json" ${GOLANG_URL} | \
              jq -r -c '.[] | select( .name | contains("go") and (contains("rc") | not ) )| .name' |\
              sort |\
              tail -1 \
              )
LAST_VERSION="${FULL_LAST_VERSION:2}"

if [ "${LAST_VERSION}" ]; then
  sed -i -e "s|GOLANG_VERSION='.*'|GOLANG_VERSION='${LAST_VERSION}'|" Dockerfile*
fi

if output=$(git status --porcelain) && [ -z "$output" ]; then
  # Working directory clean
  echo "No new version available!"
else 
  # Uncommitted changes
  git commit -a -m "update to version: ${LAST_VERSION}"
  git push
fi
