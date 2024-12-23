# Defines the namespaces of the stack.
resource "local_file" "namespaces" {
  filename = abspath(pathexpand("./namespaces.yaml"))
  content = <<EOT
apiVersion: v1
kind: Namespace
metadata:
  name: ${var.settings.cluster.identifier}
EOT
}