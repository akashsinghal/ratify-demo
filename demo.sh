#!/bin/bash

. ./util.sh

run 'clear'

desc "View Referrers attached to a subject image that is signed"
run "oras discover localhost:5000/demo:signed"

desc "View Referrers attached to a subject image that is NOT signed"
run "oras discover localhost:5000/demo:unsigned"

desc "Install Gatekeeper on local cluster"
run ""

desc "Apply the Ratify constraints"
run "kubectl apply -f template.yaml"
run "kubectl apply -f constraint.yaml"

desc "View the Ratify constraint"
run "code constraint.yaml"

desc "View the Ratify constraint template"
run "code template.yaml"

desc "Install Ratify in local cluster"
run ""

desc "Run a signed image"
run ""

desc "Run an unsigned image"
run ""

desc "Check the Ratify logs"
run ""