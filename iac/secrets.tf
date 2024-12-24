# Required variables.
locals {
  htpasswd   = "${var.settings.dataflow.auth.user}:${bcrypt(var.settings.dataflow.auth.password)}"
  clientJass = "org.apache.kafka.common.security.plain.PlainLoginModule required username=\"${var.settings.dataflow.auth.user}\" password=\"${var.settings.dataflow.auth.password}\";"
  serverJaas = <<EOT
KafkaServer {
    org.apache.kafka.common.security.plain.PlainLoginModule required
    username="${var.settings.dataflow.auth.user}"
    password="${var.settings.dataflow.auth.password}"
    user_${var.settings.dataflow.auth.user}="${var.settings.dataflow.auth.password}";
};
EOT
}

# Defines the secrets of the stack.
resource "local_file" "secrets" {
  filename = abspath(pathexpand("./secrets.yaml"))
  content = <<EOT
apiVersion: v1
kind: Secret
metadata:
  name: proxy-auth
  namespace: ${var.settings.cluster.identifier}
data:
  .htpasswd: ${base64encode(local.htpasswd)}
---
apiVersion: v1
kind: Secret
metadata:
  name: queue-broker-auth
  namespace: ${var.settings.cluster.identifier}
data:
  client_jaas.conf: ${base64encode(local.clientJass)}
  server_jaas.conf: ${base64encode(local.serverJaas)}
EOT
}