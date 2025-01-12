# Defines the issuer (LetsEncrypt) for the TLS certificate.
resource "local_file" "certIssuer" {
  filename = abspath(pathexpand("./certIssuer.yaml"))
  content = <<EOT
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-production
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: ${var.settings.general.email}
    privateKeySecretRef:
      name: letsencrypt-production-key
    solvers:
      - http01:
          ingress:
            class: traefik
EOT
}