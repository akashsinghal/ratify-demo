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

docker build --no-cache -t localhost:5000/demo:unsigned - <<EOF
FROM alpine
CMD ["echo", "test unsigned image"]
EOF
docker push localhost:5000/demo:unsigned

rm -rf ~/.config/notation
notation cert generate-test --default "ratify-demo"
notation sign localhost:5000/demo:signed

cat <<EOF > kind_config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
containerdConfigPatches:
- |-
    [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:5000"]
        endpoint = ["http://registry:5000"]
EOF

kind delete cluster --name ratify-demo 2>/dev/null || true

# Create a new kind cluster
TERM=dumb kind create cluster --name ratify-demo \
    --image kindest/node:v1.26.3 \
    --wait 5m --config=kind_config.yaml
if [ "$(docker inspect -f='{{json .NetworkSettings.Networks.kind}}' "registry")" = 'null' ]; \
    then docker network connect "kind" "registry"; fi

rm kind_config.yaml
