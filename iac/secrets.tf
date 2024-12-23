# Required variables.
locals {
  inboundAuth = "${var.settings.dataflow.inbound.auth.user}:${bcrypt(var.settings.dataflow.inbound.auth.password)}"
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
EOT
}