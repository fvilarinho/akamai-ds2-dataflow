#!/bin/bash

# Prepares the environment to execute the commands of this script.
function prepareToExecute() {
  source functions.sh

  showBanner

  cd iac || exit 1
}

# Checks the dependencies of this script.
function checkDependencies() {
  if [ -z "$DOCKER_CMD" ]; then
    echo "docker is not installed! Please install it first to continue!"

    exit 1
  fi
}

# Publishes the container images in the Docker registry.
function publish() {
  # Authenticates in the Docker registry repository.
  echo "$DOCKER_REGISTRY_PASSWORD" | $DOCKER_CMD login -u fvilarinho \
                                                          ghcr.io \
                                                          --password-stdin || exit 1

  $DOCKER_CMD push ghcr.io/fvilarinho/fluentd:latest
  $DOCKER_CMD push ghcr.io/fvilarinho/ds2-kafka-converter:latest
}

# Main function.
function main() {
  prepareToExecute
  checkDependencies
  publish
}

main