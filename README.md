# Ratify Demo

This repository contains a demo of Ratify as an external data provider for Gatekeeper in charge of blocking unsigned container images from being deployed into a local K8s cluster.

## Prerequisites
- [pv](https://ss64.com/bash/pv.html)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/)
- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
- [docker](https://docs.docker.com/get-docker/)
- [oras](https://oras.land/docs/installation)
- [notation](https://notaryproject.dev/docs/installation/cli/)
- [yq](https://github.com/mikefarah/yq)
- [helm](https://helm.sh/docs/intro/install/)

This demo requires the prerequisites above be installed before running ANY of the scripts in this repository.

## How it Works

Start by running the setup-env.sh script which:
- starts a local registry
- builds an image to be signed using the [wabbit networks](https://github.com/wabbit-networks/net-monitor) Dockerfile
- builds an image that will NOT be signed using alpine base image
- generates a test key pair and signs image using notation
- configure and create a local Kind K8s cluster

The demo will install the Gatekeeper and Ratify chart to the local K8s cluster. It then applies the policy constraints and then deploys the signed/unsigned images.

![](screengif.gif)

## Credits
Based on ORAS demos by @sajayantony and @thockin's [micro-demos](https://github.com/thockin/micro-demos)
