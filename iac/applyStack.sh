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
  echo
  echo "APPLYING NAMESPACES..."

  $KUBECTL_CMD apply -f namespaces.yaml

  echo
}

# Installs cert manager responsible to create the TLS certificate.
function applyCertManager() {
  echo "APPLYING CERT MANAGER..."

  $KUBECTL_CMD apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.16.2/cert-manager.yaml

  echo
}

# Installs the cert manager issuer.
function applyCertIssuer() {
  echo "APPLYING CERT ISSUER..."

  while true; do
    $KUBECTL_CMD apply -f certIssuer.yaml 2> /dev/null

    if [ $? -eq 0 ]; then
      break
    fi

    sleep 1
  done

  echo
}

# Credentials.
function applySecrets() {
  echo "APPLYING SECRETS..."

  $KUBECTL_CMD apply -f secrets.yaml

  echo
}

 # Settings.
function applyConfigMaps() {
  echo "APPLYING CONFIG MAPS..."

  $KUBECTL_CMD apply -f configmaps.yaml

  echo
}

# Containers.
function applyDeployments() {
  echo "APPLYING DEPLOYMENTS..."

  MANIFEST_FILENAME=deployments.yaml

  cp -f $MANIFEST_FILENAME $MANIFEST_FILENAME.tmp
  sed -i -e 's|$DOCKER_REGISTRY_URL|'"$DOCKER_REGISTRY_URL"'|g' $MANIFEST_FILENAME.tmp
  sed -i -e 's|$DOCKER_REGISTRY_ID|'"$DOCKER_REGISTRY_ID"'|g' $MANIFEST_FILENAME.tmp
  sed -i -e 's|$BUILD_VERSION|'"$BUILD_VERSION"'|g' $MANIFEST_FILENAME.tmp

  $KUBECTL_CMD apply -f $MANIFEST_FILENAME.tmp

  rm -f $MANIFEST_FILENAME.tmp*

  echo
}

# Exposed ports for communication between containers.
function applyServices() {
  echo "APPLY SERVICES..."

  $KUBECTL_CMD apply -f services.yaml

  echo
}

# Ingress.
function applyIngress() {
  echo "APPLYING INGRESS..."

  $KUBECTL_CMD apply -f ingress.yaml

  echo
  echo "Waiting until certificates get issued..."

  while true; do
    CERTIFICATE_ISSUED=$($KUBECTL_CMD get certificate \
                                      -n "$NAMESPACE" | grep ingress-tls | grep True)

    if [ -n "$CERTIFICATE_ISSUED" ]; then
      echo "Certificate was issued!"

      break
    fi

    sleep 1
  done

  echo
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