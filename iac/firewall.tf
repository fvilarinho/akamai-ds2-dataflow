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
  linodes         = local.clusterInstances
  label           = "${var.settings.general.identifier}-firewall"
  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"

  inbound {
    action   = "ACCEPT"
    label    = "allow-icmp"
    protocol = "ICMP"
    ipv4     = [ "0.0.0.0/0" ]
  }

  inbound {
    action   = "ACCEPT"
    label    = "allow-tcp-for-nodebalancers"
    protocol = "TCP"
    ports    = "30000-32767"
    ipv4     = [ "192.168.255.0/24" ]
  }

  inbound {
    action   = "ACCEPT"
    label    = "allow-udp-for-nodebalancers"
    protocol = "UDP"
    ports    = "30000-32767"
    ipv4     = [ "192.168.255.0/24" ]
  }

  inbound {
    action   = "ACCEPT"
    label    = "allowed-ips-for-ssh"
    protocol = "TCP"
    ports    = "22"
    ipv4     = [ "${jsondecode(data.http.myIp.response_body).ip}/32" ]
  }

  inbound {
    action   = "ACCEPT"
    label    = "allowed-ips-for-controlplane"
    protocol = "TCP"
    ports    = "6443"
    ipv4     = [ "${jsondecode(data.http.myIp.response_body).ip}/32" ]
  }

  inbound {
    action   = "ACCEPT"
    label    = "allowed-ips-for-inbound"
    protocol = "TCP"
    ports    = "80,443"
    ipv4     = concat(var.settings.dataflow.inbound.allowedIps.ipv4, [ "${jsondecode(data.http.myIp.response_body).ip}/32" ])
    ipv6     = var.settings.dataflow.inbound.allowedIps.ipv6
  }

  inbound {
    action   = "ACCEPT"
    label    = "allowed-ips-for-outbound"
    protocol = "TCP"
    ports    = "30093"
    ipv4     = concat(var.settings.dataflow.outbound.allowedIps.ipv4, [ "${jsondecode(data.http.myIp.response_body).ip}/32" ])
    ipv6     = var.settings.dataflow.outbound.allowedIps.ipv6
  }

  inbound {
    action   = "ACCEPT"
    label    = "allow-intracluster-tcp-traffic"
    protocol = "TCP"
    ipv4     = local.clusterInstancesIps
  }

  inbound {
    action   = "ACCEPT"
    label    = "allow-intracluster-udp-traffic"
    protocol = "UDP"
    ipv4     = local.clusterInstancesIps
  }

  depends_on = [
    data.http.myIp,
    linode_instance.clusterManager,
    linode_instance.clusterWorker,
    null_resource.clusterManagerSetup,
    null_resource.clusterWorkerSetup,
    null_resource.downloadKubeconfig,
    null_resource.applyStack
  ]
}