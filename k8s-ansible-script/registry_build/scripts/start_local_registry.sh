#!/bin/bash
REALPATH=$(realpath "$0")
DOCKER=$(dirname "$REALPATH")/../images
DIR=$(realpath "$DOCKER")
docker load < $DIR/registry.tar
docker rm -f local-registry
docker run --name local-registry -v $DIR:/var/lib/registry --restart=always -d --network host registry:2.6.2
