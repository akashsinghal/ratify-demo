#!/bin/bash

# stop containers
docker stop registry
docker stop kind-control-plane

# remove containers
docker rm registry
docker rm kind-control-plane

# delete images
docker image rm localhost:5000/demo:signed
docker image rm localhost:5000/demo:unsigned
docker image rm registry
docker image rm kindest/node:v1.26.3

# delete kind network
docker network prune -f

# remove chart repos
helm repo remove gatekeeper
helm repo remove ratify