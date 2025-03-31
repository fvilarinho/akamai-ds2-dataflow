#!/bin/bash

# Checks the dependencies of this script.
function checkDependencies() {
  export KUBECONFIG=$1

  if [ -z "$KUBECONFIG" ]; then
    echo "kubeconfig is not defined! Please define it first to continue!"

    exit 1
  fi
}

# Fetches the inbound port to be used in the node balancer configuration.
function fetchInboundPort() {
  PORT=
  SECURE_PORT=

  while true; do
    PORT=$($KUBECTL_CMD get svc traefik -n kube-system -o jsonpath='{.spec.ports[0].nodePort}')
    SECURE_PORT=$($KUBECTL_CMD get svc traefik -n kube-system -o jsonpath='{.spec.ports[1].nodePort}')

    if [ -n "$PORT" ] && [ -n "$SECURE_PORT" ]; then
      break
    fi

    sleep 1
  done

  echo "{\"port\": \"$PORT\", \"securePort\": \"$SECURE_PORT\"}"
}

# Main function.
function main() {
  checkDependencies "$1"
  fetchInboundPort
}

main "$1"