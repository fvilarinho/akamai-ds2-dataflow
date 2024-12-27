#!/bin/bash

# Prepares the environment to execute the commands of this script.
function prepareToExecute() {
  source functions.sh

  showBanner
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
  echo "$DOCKER_REGISTRY_PASSWORD" | $DOCKER_CMD login -u $DOCKER_REGISTRY_ID \
                                                          $DOCKER_REGISTRY_URL \
                                                          --password-stdin || exit 1

  $DOCKER_CMD push $DOCKER_REGISTRY_URL/$DOCKER_REGISTRY_ID/fluentd:$BUILD_VERSION
  $DOCKER_CMD push $DOCKER_REGISTRY_URL/$DOCKER_REGISTRY_ID/ds2-kafka-converter:$BUILD_VERSION
}

# Main function.
function main() {
  prepareToExecute
  checkDependencies
  publish
}

main