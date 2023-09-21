#!/bin/bash

. ./util.sh

run 'clear'

desc "View resources installed on cluster"
run "kubectl get deployment -n gatekeeper-system"

desc "View Referrers attached to a subject image that is signed"
run "oras discover localhost:5000/demo:signed"

desc "View Referrers attached to a subject image that is NOT signed"
run "oras discover localhost:5000/demo:unsigned"

desc "Run a signed image"
run "kubectl run demo --image=registry:5000/demo:signed"

desc "Run an unsigned image"
run "kubectl run demo2 --image=registry:5000/demo:unsigned"

desc "Check the Ratify logs"
run "kubectl logs deployment/ratify -n gatekeeper-system"