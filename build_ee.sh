#!/bin/bash
# Build the Execution Environment

EE_REGISTRY_URL=${1:=git.element-networks.nl/ansible/ee-base}

# Stage 1: Base OS image with all tools installed from Package manager
ansible-builder build -f execution-environment-stage1.yml -t ansible-ee-base:stage1-latest
# Stage 2: Extra tools that require tools to be present in image (does not work (yet?) in Stage 1)
ansible-builder build -f execution-environment-stage2.yml -t ansible-ee-base:stage2-latest

# Upload to Registry as latest
IMAGE_ID=$(podman image inspect ansible-ee-base:stage2-latest | jq -r .[].Id)
podman push $IMAGE_ID docker://$EE_REGISTRY_URL:latest
