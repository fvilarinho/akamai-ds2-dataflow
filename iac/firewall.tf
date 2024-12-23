# Required variables.
locals {
  clusterInstancesIps = flatten([ for clusterInstance in data.linode_instances.clusterInstances.instances : [ "${clusterInstance.ip_address}/32", "${clusterInstance.private_ip_address}/32" ]])
}

# Fetches the local IP.
data "http" "myIp" {
  url = "https://ipinfo.io"
}

# Definition of the firewall rules.
resource "linode_firewall" "cluster" {
  label           = "${var.settings.cluster.identifier}-firewall"
  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"

  linodes = local.clusterInstances

  inbound {
    action   = "ACCEPT"
    label    = "allow-icmp"
    protocol = "ICMP"
    ipv4     = [ "0.0.0.0/0" ]
  }

  inbound {
    action   = "ACCEPT"
    label    = "allowed-ips"
    protocol = "TCP"
    ipv4     = concat(var.settings.cluster.allowedIps.ipv4, [ "${jsondecode(data.http.myIp.response_body).ip}/32" ])
    ipv6     = var.settings.cluster.allowedIps.ipv6
  }

  inbound {
    action   = "ACCEPT"
    label    = "allowed-ips"
    protocol = "UDP"
    ipv4     = concat(var.settings.cluster.allowedIps.ipv4, [ "${jsondecode(data.http.myIp.response_body).ip}/32" ])
    ipv6     = var.settings.cluster.allowedIps.ipv6
  }

  inbound {
    action   = "ACCEPT"
    label    = "allow-intracluster-traffic"
    protocol = "TCP"
    ipv4     = local.clusterInstancesIps
  }

  inbound {
    action   = "ACCEPT"
    label    = "allow-intracluster-traffic"
    protocol = "UDP"
    ipv4     = local.clusterInstancesIps
  }

  depends_on = [
    data.http.myIp,
    linode_instance.clusterManager,
    linode_instance.clusterWorker,
    null_resource.clusterManagerSetup,
    null_resource.clusterWorkerSetup,
    null_resource.stackSetup,
    null_resource.applyStack
  ]
}