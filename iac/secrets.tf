# Required local variables.
locals {
  htpasswd   = "${var.settings.dataflow.inbound.auth.user}:${bcrypt(var.settings.dataflow.inbound.auth.password)}"
  serverJaas = <<EOT
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
  name: proxy-auth
  namespace: ${var.settings.general.identifier}
data:
  .htpasswd: ${base64encode(local.htpasswd)}
---
apiVersion: v1
kind: Secret
metadata:
  name: queue-broker-auth
  namespace: ${var.settings.general.identifier}
data:
  server_jaas.conf: ${base64encode(local.serverJaas)}
EOT
}