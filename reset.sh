#!/bin/bash

# delete kind cluster
echo "Deleting kind cluster"
kind delete cluster --name ratify-demo 2>/dev/null || true

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

# remove ratify demo certs and keys
notation cert delete --type ca --store ratify-demo --all
notation key ls | grep ratify-demo | awk '{ system("notation key delete " $2); system("rm " $3); system("rm " $4);}'
cat ~/.config/notation/signingkeys.json
