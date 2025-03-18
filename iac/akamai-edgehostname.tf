# Definition of the Edge Hostname. This is the hostname that must be used in the Edge DNS entries
# of all hostnames that will pass through the CDN.
resource "akamai_edge_hostname" "default" {
  contract_id   = var.settings.general.contract
  group_id      = var.settings.general.group
  product_id    = var.settings.general.product
  edge_hostname = "${var.settings.general.identifier}.${var.settings.general.domain}.edgesuite.net"
  ip_behavior   = "IPV4"
}