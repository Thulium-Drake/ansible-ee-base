#!/bin/bash
# Build the Execution Environments
EE_VERSIONS="$(ls *.yml)"
EE_REGISTRY_URL=git.zm1.element-networks.nl/ansible

for i in $EE_VERSIONS
do
  ansible-builder build -v3 -f ${i} -t ee-${i%%.yml}:latest
  IMAGE_ID=$(podman image inspect ee-${i%%.yml}:latest | jq -r .[].Id)
  podman push $IMAGE_ID $EE_REGISTRY_URL/ee-${i%%.yml}:latest
done
