#!/bin/bash

# Shows the labels.
function showLabel() {
  if [[ "$0" == *"build.sh"* ]]; then
    echo "*** BUILD ***"
  elif [[ "$0" == *"package.sh"* ]]; then
    echo "*** PACKAGE ***"
  elif [[ "$0" == *"publish.sh"* ]]; then
    echo "*** PUBLISH ***"
  elif [[ "$0" == *"undeploy.sh"* ]]; then
    echo "*** UNDEPLOY ***"
  elif [[ "$0" == *"deploy.sh"* ]]; then
    echo "*** DEPLOY ***"
  elif [[ "$0" == *"test.sh"* ]]; then
    echo "*** TEST ***"
  fi
}

# Shows the banner.
function showBanner() {
  if [ -f banner.txt ]; then
    cat banner.txt
  fi

  showLabel $1
}

# Prepares the environment to execute the commands of this script.
function prepareToExecute() {
  # Mandatory binaries.
  export JAVA_CMD=$(which java)
  export CURL_CMD=$(which curl)
  export DOCKER_CMD=$(which docker)
  export TERRAFORM_CMD=$(which terraform)
  export KUBECTL_CMD=$(which kubectl)

  # Mandatory environment variables.
  export WORK_DIR="$(pwd)/iac"
  export BUILD_ENV_FILENAME=$WORK_DIR/.env

  if [ -e "$BUILD_ENV_FILENAME" ]; then
    source "$BUILD_ENV_FILENAME"
  fi
}

prepareToExecute