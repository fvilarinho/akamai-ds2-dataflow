locals {
  testStatusCodeAttribute = "{http_code}"
}

resource "local_file" "test" {
  filename = abspath(pathexpand("../test.sh"))
  content = <<EOT
#!/bin/bash

source functions.sh

index=0

while true; do
  timestamp=$(date +%s)
  statusCode=$($CURL_CMD -o /dev/null \
                         -s \
                         -w "%${local.testStatusCodeAttribute}" \
                         -X POST \
                         -H "Content-Type: application/json" \
                         -H "Accept: application/json" \
                         -u "${var.settings.dataflow.inbound.auth.user}:${var.settings.dataflow.inbound.auth.password}" \
                         https://${linode_instance.clusterManager.ip_address}/ingest \
                         -d "{\"index\": $index, \"timestamp\": $timestamp}" \
                         --insecure)

  echo "Index: $index, Timestamp: $timestamp, Status Code: $statusCode"

  ((index++))

  sleep 1
done

EOT
}