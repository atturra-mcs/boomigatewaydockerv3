#!/bin/bash

if [[ $# -eq 0 ]] ; then
  echo "Usage       : $0 <configuration>"
  echo "Where configuration is boomibase, boomigateway, run, tag or push"
  exit 100
fi

declare -A properties
while IFS='=' read -d $'\n' -r k v; do
  [[ "$k" =~ ^([[:space:]]*|[[:space:]]*#.*)$ ]] && continue
  properties[$k]="$v"
done < build.properties

export buildtype=$1

set -x
case $buildtype in

  base | boomibase)
    cd src/install
    docker build . -t boomibase/${properties["currentVersion"]}
    ;;

  boomigateway)
    cd src/gateway
    docker build . -t boomigateway/${properties["currentVersion"]}
    ;;

  run)
    mkdir -p /tmp/boomigateway/
    docker run -d -t -i \
    -e BOOMI_USERNAME=${properties["username"]} \
    -e BOOMI_PASSWORD=${properties["password"]} \
    -e BOOMI_ACCOUNTID=${properties["accountId"]} \
    -e BOOMI_ATOMNAME=${properties["atomName"]} \
    -e ATOM_LOCALHOSTID='localhost' \
    -v /mnt/boomi/:/tmp/boomigateway/:Z \
    boomigateway/${properties["currentVersion"]}
    ;;

  tag)
    docker tag boomigateway/${properties["currentVersion"]} ${properties["dockerHubRepo"]}:${properties["outputVersion"]}
    ;;

  push)
    docker push ${properties["dockerHubRepo"]}:${properties["outputVersion"]}
    ;;
  *)
    echo -n "Unknown configuration"
    ;;
esac

set +x