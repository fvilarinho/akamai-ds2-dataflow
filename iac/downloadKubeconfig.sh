#!/bin/bash

# Check the dependencies of this script.
function checkDependencies() {
  if [ -z "$CLUSTER_MANAGER_IP" ]; then
    echo "Please specify the cluster manager IP!"

    exit 1
  fi

  if [ -z "$SSH_PRIVATE_KEY_FILENAME" ]; then
    echo "Please specify the SSH private key filename!"

    exit 1
  fi

  if [ -z "$KUBECONFIG_FILENAME" ]; then
    echo "Please specify the kubeconfig filename!"

    exit 1
  fi
}

# Downloads the kubeconfig file from the remote server and make it available locally.
function download() {
  TEMP_KUBECONFIG_FILENAME=./.kubeconfig.tmp

  scp -o StrictHostKeyChecking=no \
      -o UserKnownHostsFile=/dev/null \
      -i "$SSH_PRIVATE_KEY_FILENAME" \
      root@"$CLUSTER_MANAGER_IP":/etc/rancher/k3s/k3s.yaml $TEMP_KUBECONFIG_FILENAME

  # Replaces with the remote server IP.
  sed -i -e 's|127.0.0.1|'"$CLUSTER_MANAGER_IP"'|g' $TEMP_KUBECONFIG_FILENAME

  mv $TEMP_KUBECONFIG_FILENAME "$KUBECONFIG_FILENAME"

  # Clean-up.
  rm -f $TEMP_KUBECONFIG_FILENAME*
}

# Main function.
function main() {
  checkDependencies
  download
}

main