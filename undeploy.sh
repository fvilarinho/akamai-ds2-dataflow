#!/bin/bash

# Checks the dependencies for this script.
function checkDependencies() {
  if [ -z "$TERRAFORM_CMD" ]; then
    echo "terraform is not installed! Please install it first to continue!"

    exit 1
  fi
}

# Prepares the environment to execute this script.
function prepareToExecute() {
  source functions.sh

  showBanner

  cd iac || exit 1
}

# Undeploys the provisioned infrastructure.
function undeploy() {
  $TERRAFORM_CMD init \
                 -upgrade \
                 -migrate-state || exit 1

  $TERRAFORM_CMD destroy \
                 -auto-approve
}

# Clean-up.
function cleanUp() {
  rm -f .kubeconfig
}

# Main function.
function main() {
  prepareToExecute
  checkDependencies
  undeploy
  cleanUp
}

main