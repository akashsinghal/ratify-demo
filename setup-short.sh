#!/bin/bash

. ./setup.sh

# Install Gatekeeper on the cluster
helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts
helm install gatekeeper/gatekeeper \
    --name-template=gatekeeper \
    --namespace gatekeeper-system \
    --create-namespace \
    --set auditInterval=0 \
    --set enableExternalData=true \
    --set validatingWebhookTimeoutSeconds=5 \
    --set mutatingWebhookTimeoutSeconds=2

# Apply Constraint and constraint template
kubectl apply -f template.yaml
kubectl apply -f constraint.yaml

# Install Ratify on the cluster
helm repo add ratify https://deislabs.github.io/ratify
helm install ratify ratify/ratify \
    --atomic \
    --namespace gatekeeper-system \
    --set-file notaryCert=$(notation cert ls | grep ratify-demo) \
    --set oras.useHttp=true
