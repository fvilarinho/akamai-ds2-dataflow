#!/bin/bash

function checkDependencies() {
  if [ -z "$KUBECTL_CMD" ]; then
    echo "kubectl is not installed! Please install it first to continue!"

    exit 1
  fi
}

function prepareToExecute() {
  export KUBECTL_CMD=$(which kubectl)
}

# Creates the required namespaces.
function applyNamespaces() {
  $KUBECTL_CMD apply -f namespaces.yaml
}

# Installs cert manager responsible to create the TLS certificate.
function applyCertManager() {
  $KUBECTL_CMD apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.16.2/cert-manager.yaml
}

# Installs the cert manager issuer.
function applyCertIssuer() {
  while true; do
    $KUBECTL_CMD apply -f certissuer.yaml 2> /dev/null

    if [ $? -eq 0 ]; then
      break
    fi

    sleep 1
  done
}

# Credentials.
function applySecrets() {
  $KUBECTL_CMD apply -f secrets.yaml
}

 # Settings.
function applyConfigMaps() {
  $KUBECTL_CMD apply -f configmaps.yaml
}

# Containers.
function applyDeployments() {
  $KUBECTL_CMD apply -f deployments.yaml
}

# Exposed ports for communication between containers.
function applyServices() {
  $KUBECTL_CMD apply -f services.yaml
}

# Ingress.
function applyIngress() {
  $KUBECTL_CMD apply -f ingress.yaml

  while true; do
    CERTIFICATE_ISSUED=$($KUBECTL_CMD get certificate -n akamai-ds2-dataflow | grep ingress-tls | grep True)

    if [ -n "$CERTIFICATE_ISSUED" ]; then
      break
    fi

    sleep 1
  done
}

function main() {
  prepareToExecute
  checkDependencies
  applyNamespaces
  applyCertManager
  applyCertIssuer
  applySecrets
  applyConfigMaps
  applyDeployments
  applyServices
  applyIngress
}

main