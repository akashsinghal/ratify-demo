#!/bin/bash

# create registry container unless it already exists
reg_name='registry'
reg_port='5000'
if [ "$(docker inspect -f '{{.State.Running}}' "${reg_name}" 2>/dev/null || true)" != 'true' ]; then
  docker run \
    -d --restart=always -p "127.0.0.1:${reg_port}:5000" --name "${reg_name}" \
    -e REGISTRY_STORAGE_DELETE_ENABLED=true \
    registry:2
fi

# Create a new kind cluster
cat <<EOF | kind create cluster \
    --name ratify-demo \
    --image kindest/node:v1.26.3 \
    --wait 5m --config=-
kind: Cluster
name: ratify-demo
apiVersion: kind.x-k8s.io/v1alpha4
containerdConfigPatches:
- |-
    [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:5000"]
        endpoint = ["http://registry:5000"]
EOF

# connect the registry to the cluster network if not already connected
if [ "$(docker inspect -f='{{json .NetworkSettings.Networks.kind}}' "registry")" = 'null' ]; then 
    docker network connect "kind" "registry"; 
fi

# Build and sign the images
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
