#!/bin/bash

# Check the dependencies of this script.
function checkDependencies() {
  export KUBECONFIG=$1

  if [ -z "$KUBECONFIG" ]; then
    echo "kubeconfig is not defined! Please define it first to continue!"

    exit 1
  fi
}

# Fetches the inbound port for the node balancer.
function fetchInboundPort() {
  echo "{\"port\": \"$($KUBECTL_CMD get svc traefik -n kube-system -o jsonpath='{.spec.ports[1].nodePort}')\"}"
}

# Main function.
function main() {
  checkDependencies "$1"
  fetchInboundPort
}

main "$1"