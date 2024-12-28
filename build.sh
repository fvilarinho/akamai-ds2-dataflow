#!/bin/bash

# Prepares the environment to execute this script.
function prepareToExecute() {
  source functions.sh

  showBanner
}

# Checks the dependencies of this script.
function checkDependencies() {
  if [ -z "$JAVA_CMD" ]; then
    echo "java is not installed! Please install it first to continue!"

    exit 1
  fi
}

# Builds the services.
function build() {
  echo Building converter...

  ./gradlew clean build --warning-mode all
}

# Main function.
function main() {
  prepareToExecute
  checkDependencies
  build
}

main