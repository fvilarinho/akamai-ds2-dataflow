# Required local variables.
locals {
  # Creates a indented list with all cluster instances hostnames.
  clusterHostnamesTabulation = join("", tolist([for index in range(7) : " "]))
  clusterHostnamesList = concat([ for clusterInstance in data.linode_instances.clusterInstances.instances : "${local.clusterHostnamesTabulation} - ${replace(clusterInstance.ip_address, ".", "-")}.ip.linodeusercontent.com" ],
                                [ "${local.clusterHostnamesTabulation} - ${linode_nodebalancer.inbound.hostname}" ])
}

# Defines the rules for the ingress traffic in the stack.
resource "local_file" "ingress" {
  filename = abspath(pathexpand("./ingress.yaml"))
  content = <<EOT
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress
  namespace: ${var.settings.general.identifier}
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-production
spec:
  ingressClassName: traefik
  tls:
    - hosts:
${join("\n", local.clusterHostnamesList)}
      secretName: ingress-tls
  rules:
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: proxy
                port:
                  number: 80
EOT

  depends_on = [
    linode_instance.clusterManager,
    linode_instance.clusterWorker,
    data.linode_instances.clusterInstances,
    linode_nodebalancer.inbound,
    linode_nodebalancer_config.inbound
  ]
}