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

# configure
name="ratify-demo"
config_dir="$HOME/.config/notation"

# extract paths
key_json=$(cat "$config_dir/signingkeys.json" | jq ".keys[] | select(.name==\"$name\")")
key_path=$(echo "$key_json" | jq -r .keyPath)
cert_path=$(echo "$key_json" | jq -r .certPath)

# clean up keys
notation key delete -v $name
notation cert delete -y --type ca --store $name $name.crt
rm -v "$key_path" "$cert_path"
rmdir -v "$config_dir/localkeys" || true