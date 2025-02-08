# Required local variables.
locals {
  # Variables used by curl to store the request status code.
  testStatusCodeAttribute = "{http_code}"
}

# Creates the test script.
resource "local_file" "test" {
  filename = abspath(pathexpand("../test.sh"))
  file_permission = "0700"
  content = <<EOT
#!/bin/bash

# Prepares the environment to execute this script.
function prepareToExecute() {
  source functions.sh

  showBanner
}

# Check the dependencies of this script.
function checkDependencies() {
  if [ -z "$CURL_CMD" ]; then
    echo "curl is not installed! Please install it first to continue!"

    exit 1
  fi
}

# Execute the test in loop.
function test() {
  host=${linode_instance.clusterManager.ip_address}
  url=https://$host/ingest
  credentials="${var.settings.dataflow.inbound.auth.user}:${var.settings.dataflow.inbound.auth.password}"
  index=0

  while true; do
    timestamp=$(date +%s)
    statusCode=$($CURL_CMD -o /dev/null \
                           -s \
                           -w "%${local.testStatusCodeAttribute}" \
                           -X POST \
                           -H "Content-Type: application/json" \
                           -H "Accept: application/json" \
                           -u "$credentials" \
                           "$url" \
                           -d "{\"index\": $index, \"timestamp\": $timestamp}" \
                           --insecure)

    echo "Timestamp: $timestamp, URL: $url, Index: $index, Status Code: $statusCode"

    ((index++))

    sleep 1
  done
}

# Main function.
function main() {
  prepareToExecute
  checkDependencies
  test
}

main
EOT

  depends_on = [ linode_instance.clusterManager ]
}