#!/bin/bash

docker pull registry
docker run -d \
    -p 5000:5000 \
    --restart=always \
    --name registry \
    -e REGISTRY_STORAGE_DELETE_ENABLED=true \
    registry
sleep 5

docker build --no-cache -t localhost:5000/demo:signed github.com/wabbit-networks/net-monitor
docker push localhost:5000/demo:signed

printf 'FROM alpine\nCMD ["echo", "test unsigned image"]' > Dockerfile
docker build --no-cache -t localhost:5000/demo:unsigned .
rm Dockerfile
docker push localhost:5000/demo:unsigned

rm -rf ~/.config/notation
notation cert generate-test --default "ratify-demo"
notation sign --insecure-registry localhost:5000/demo:signed

printf 'kind: Cluster\napiVersion: kind.x-k8s.io/v1alpha4\ncontainerdConfigPatches:\n- |-\n  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:5000"]\n    endpoint = ["http://registry:5000"]' > kind_config.yaml

# Check for existing kind cluster
if [ $(kind get clusters) ]; then kind delete cluster; fi
# Create a new kind cluster
TERM=dumb kind create cluster --image kindest/node:v1.26.3 --wait 5m --config=kind_config.yaml
if [ "$(docker inspect -f='{{json .NetworkSettings.Networks.kind}}' "registry")" = 'null' ]; then docker network connect "kind" "registry"; fi
rm kind_config.yaml
