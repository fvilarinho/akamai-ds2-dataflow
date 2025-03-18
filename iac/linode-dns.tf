# Fetches the DNS zone.
data "linode_domain" "default" {
  domain = var.settings.general.domain
}

# Adds the DNS domain record.
resource "linode_domain_record" "default" {
  domain_id   = data.linode_domain.default.id
  name        = var.settings.general.identifier
  record_type = "CNAME"
  target      = akamai_edge_hostname.default.edge_hostname
  ttl_sec     = 30

  depends_on = [
    data.linode_domain.default,
    akamai_edge_hostname.default
  ]
}

data "akamai_property_hostnames" "default" {
  contract_id = var.settings.general.contract
  group_id    = var.settings.general.group
  property_id = akamai_property.default.id
  version     = akamai_property.default.latest_version
  depends_on  = [
    akamai_property.default,
    akamai_property_activation.staging,
    akamai_property_activation.production
  ]
}

resource "linode_domain_record" "certificateValidation" {
  domain_id   = data.linode_domain.default.id
  name        = data.akamai_property_hostnames.default.hostnames[0].cert_status[0].hostname
  record_type = "CNAME"
  target      = data.akamai_property_hostnames.default.hostnames[0].cert_status[0].target
  ttl_sec     = 30
  depends_on  = [
    data.akamai_property_hostnames.default,
    akamai_property.default,
    akamai_property_activation.staging,
    akamai_property_activation.production
  ]
}