#!/bin/bash
# Build the Execution Environment

# Stop execution when an error occurs in any of the builder commands
set -e

EE_REGISTRY_URL=${1:=git.element-networks.nl/ansible/ee-base}
ANSIBLE_VERSION=$2

if [ -z "$2" ]
then
  ANSIBLE_VERSION=2.14
fi

# Stage 1: Base OS image with all tools installed from Package manager
sed -i "s/ANSIBLE_VERSION/$ANSIBLE_VERSION/" execution-environment-stage1.yml
ansible-builder build -v3 -f execution-environment-stage1.yml -t ansible-ee-base:stage1-latest
# Stage 2: Extra tools that require tools to be present in image (does not work (yet?) in Stage 1)
ansible-builder build -v3 -f execution-environment-stage2.yml -t ansible-ee-base:stage2-latest

# Upload to Registry as latest
IMAGE_ID=$(podman image inspect ansible-ee-base:stage2-latest | jq -r .[].Id)
podman push $IMAGE_ID docker://$EE_REGISTRY_URL:latest

# Clean up
git reset --hard
