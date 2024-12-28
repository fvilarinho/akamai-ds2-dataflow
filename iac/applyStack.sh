#!/bin/bash

# Check the dependencies of this script.
function checkDependencies() {
  if [ -z "$KUBECONFIG" ]; then
    echo "Please specify the kubeconfig filename!"

    exit 1
  fi

  if [ -z "$NAMESPACE" ]; then
    echo "Please specify the namespace!"

    exit 1
  fi
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
  manifestFilename=deployments.yaml

  cp -f $manifestFilename $manifestFilename.tmp
  sed -i -e 's|$DOCKER_REGISTRY_URL|'"$DOCKER_REGISTRY_URL"'|g' $manifestFilename.tmp
  sed -i -e 's|$DOCKER_REGISTRY_ID|'"$DOCKER_REGISTRY_ID"'|g' $manifestFilename.tmp
  sed -i -e 's|$BUILD_VERSION|'"$BUILD_VERSION"'|g' $manifestFilename.tmp

  $KUBECTL_CMD apply -f $manifestFilename.tmp

  rm -f $manifestFilename.tmp*
}

# Exposed ports for communication between containers.
function applyServices() {
  $KUBECTL_CMD apply -f services.yaml
}

# Ingress.
function applyIngress() {
  $KUBECTL_CMD apply -f ingress.yaml

  while true; do
    CERTIFICATE_ISSUED=$($KUBECTL_CMD get certificate \
                                      -n "$NAMESPACE" | grep ingress-tls | grep True)

    if [ -n "$CERTIFICATE_ISSUED" ]; then
      break
    fi

    sleep 1
  done
}

# Main function.
function main() {
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