# Required local variables.
locals {
  inboundCredentials = "${var.settings.dataflow.inbound.auth.user}:${bcrypt(var.settings.dataflow.inbound.auth.password)}"
  outboundCredentials = <<EOT
    KafkaServer {
      org.apache.kafka.common.security.plain.PlainLoginModule required username="${var.settings.dataflow.outbound.auth.user}" password="${var.settings.dataflow.outbound.auth.password}" user_${var.settings.dataflow.outbound.auth.user}="${var.settings.dataflow.outbound.auth.password}";
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
  name: queue-broker-auth
  namespace: ${var.settings.general.identifier}
data:
  server_jaas.conf: ${base64encode(local.outboundCredentials)}
---
apiVersion: v1
kind: Secret
metadata:
  name: grafana-auth
  namespace: ${var.settings.general.identifier}
data:
  username: ${base64encode(var.settings.dataflow.inbound.auth.user)}
  password: ${base64encode(var.settings.dataflow.inbound.auth.password)}
---
apiVersion: v1
kind: Secret
metadata:
  name: proxy-auth
  namespace: ${var.settings.general.identifier}
data:
  .htpasswd: ${base64encode(local.inboundCredentials)}
EOT
}