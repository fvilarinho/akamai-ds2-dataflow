# Required variables.
locals {
  htpasswd = "${var.settings.dataflow.auth.user}:${bcrypt(var.settings.dataflow.auth.password)}"
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
EOT
}