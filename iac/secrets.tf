# Required variables.
locals {
  inboundAuth  = "${var.settings.dataflow.auth.user}:${bcrypt(var.settings.dataflow.auth.password)}"
  outboundAuth = <<EOT
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
  .htpasswd: ${base64encode(local.inboundAuth)}
---
apiVersion: v1
kind: Secret
metadata:
  name: queue-broker-auth
  namespace: ${var.settings.cluster.identifier}
data:
  jaas.conf: ${base64encode(local.outboundAuth)}
  user: ${base64encode(var.settings.dataflow.auth.user)}
  password: ${base64encode(var.settings.dataflow.auth.password)}
EOT
}