#!/bin/bash

. ./util.sh

run 'clear'

desc "View Referrers attached to a subject image that is signed"
run "oras discover --plain-http localhost:5000/demo:signed"

desc "View Referrers attached to a subject image that is NOT signed"
run "oras discover --plain-http localhost:5000/demo:unsigned"

desc "Install Gatekeeper on local cluster"
run "helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts"
run "helm install gatekeeper/gatekeeper  --name-template=gatekeeper --namespace gatekeeper-system --create-namespace --set enableExternalData=true --set validatingWebhookTimeoutSeconds=5 --set mutatingWebhookTimeoutSeconds=2"

desc "Apply the Ratify constraints"
run "kubectl apply -f template.yaml"
run "kubectl apply -f constraint.yaml"

desc "View the Ratify constraint"
run "code constraint.yaml"

desc "View the Ratify constraint template"
run "code template.yaml"

desc "Install Ratify in local cluster"
run "helm repo add ratify https://deislabs.github.io/ratify"
run "helm install ratify ratify/ratify --atomic --namespace gatekeeper-system --set-file notaryCert=~/.config/notation/localkeys/ratify-demo.crt --set featureFlags.RATIFY_CERT_ROTATION=true --set oras.useHttp=true"

desc "Run a signed image"
run "kubectl run demo --image=registry:5000/demo:signed"

desc "Run an unsigned image"
run "kubectl run demo2 --image=registry:5000/demo:unsigned"

desc "Check the Ratify logs"
run "kubectl logs deployment/ratify -n gatekeeper-system"