#!/bin/sh

set -e

echo "Forwarding registry to localhost"

socat TCP-LISTEN:5000,fork,reuseaddr TCP:registry:5000 &