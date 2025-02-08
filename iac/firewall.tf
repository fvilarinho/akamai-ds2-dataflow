# Required local variables.
locals {
  # List containing the cluster instances IPs.
  clusterInstancesIps = flatten([ for clusterInstance in data.linode_instances.clusterInstances.instances : [ "${clusterInstance.ip_address}/32", "${clusterInstance.private_ip_address}/32" ]])
}

# Fetches the local public IP.
data "http" "myIp" {
  url = "https://ipinfo.io"
}

# Definition of the firewall rules.
resource "linode_firewall" "cluster" {
  label           = "${var.settings.general.identifier}-firewall"
  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"

  linodes = local.clusterInstances

  # Allows ICMP for all traffic.
  inbound {
    action   = "ACCEPT"
    label    = "allow-icmp"
    protocol = "ICMP"
    ipv4     = [ "0.0.0.0/0" ]
    ipv6     = [ "::/0" ]
  }

  # Allow TCP traffic for Node Balancers.
  inbound {
    action   = "ACCEPT"
    label    = "allow-tcp-for-nodebalancers"
    protocol = "TCP"
    ports    = "30000-32767"
    ipv4     = [ "192.168.255.0/24" ]
  }

  # Allow UDP traffic for Node Balancers.
  inbound {
    action   = "ACCEPT"
    label    = "allow-udp-for-nodebalancers"
    protocol = "UDP"
    ports    = "30000-32767"
    ipv4     = [ "192.168.255.0/24" ]
  }

  # Allow SSH only for the local public IP.
  inbound {
    action   = "ACCEPT"
    label    = "allowed-ips-for-ssh"
    protocol = "TCP"
    ports    = "22"
    ipv4     = concat(var.settings.cluster.allowedIps.ipv4, [ "${jsondecode(data.http.myIp.response_body).ip}/32" ])
    ipv6     = var.settings.cluster.allowedIps.ipv6
  }

  # Allow Kubernetes control plane access only for the local public IP.
  inbound {
    action   = "ACCEPT"
    label    = "allowed-ips-for-controlplane"
    protocol = "TCP"
    ports    = "6443"
    ipv4     = concat(var.settings.cluster.allowedIps.ipv4, [ "${jsondecode(data.http.myIp.response_body).ip}/32" ])
    ipv6     = var.settings.cluster.allowedIps.ipv6
  }

  # Allow inbound traffic.
  inbound {
    action   = "ACCEPT"
    label    = "allowed-ips-for-inbound"
    protocol = "TCP"
    ports    = "443"
    ipv4     = concat(var.settings.dataflow.inbound.allowedIps.ipv4, [ "${jsondecode(data.http.myIp.response_body).ip}/32" ])
    ipv6     = var.settings.dataflow.inbound.allowedIps.ipv6
  }

  # Allow outbound traffic.
  inbound {
    action   = "ACCEPT"
    label    = "allowed-ips-for-outbound"
    protocol = "TCP"
    ports    = "30093"
    ipv4     = concat(var.settings.dataflow.outbound.allowedIps.ipv4, [ "${jsondecode(data.http.myIp.response_body).ip}/32" ])
    ipv6     = var.settings.dataflow.outbound.allowedIps.ipv6
  }

  # Allow intra cluster traffic for TCP.
  inbound {
    action   = "ACCEPT"
    label    = "allow-intracluster-tcp-traffic"
    protocol = "TCP"
    ports    = "1-65535"
    ipv4     = local.clusterInstancesIps
  }

  # Allow intra cluster traffic for UDP.
  inbound {
    action   = "ACCEPT"
    label    = "allow-intracluster-udp-traffic"
    protocol = "UDP"
    ports    = "1-65535"
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