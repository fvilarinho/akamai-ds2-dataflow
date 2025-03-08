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
resource "linode_firewall" "clusterNodes" {
  label           = "${var.settings.general.identifier}-cn-fw"
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

  # Allow node balancers traffic.
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

  # Allow SSH only for the local public IP.
  inbound {
    action   = "ACCEPT"
    label    = "allowed-ips-for-ssh"
    protocol = "TCP"
    ports    = "22"
    ipv4     = concat(var.settings.cluster.allowedIps.ipv4, [ "${jsondecode(data.http.myIp.response_body).ip}/32" ])
    ipv6     = concat(var.settings.cluster.allowedIps.ipv6, [ "::1/128" ])
  }

  # Allow Kubernetes control plane access only for the local public IP.
  inbound {
    action   = "ACCEPT"
    label    = "allowed-ips-for-controlplane"
    protocol = "TCP"
    ports    = "6443"
    ipv4     = concat(var.settings.cluster.allowedIps.ipv4, [ "${jsondecode(data.http.myIp.response_body).ip}/32" ])
    ipv6     = concat(var.settings.cluster.allowedIps.ipv6, [ "::1/128" ])
  }

  # Allow inbound traffic.
  inbound {
    action   = "ACCEPT"
    label    = "allowed-ips-for-inbound"
    protocol = "TCP"
    ports    = "443"
    ipv4     = concat(var.settings.dataflow.inbound.allowedIps.ipv4, [ "${jsondecode(data.http.myIp.response_body).ip}/32" ])
    ipv6     = concat(var.settings.dataflow.inbound.allowedIps.ipv6, [ "::1/128" ])
  }

  # Allow outbound traffic.
  inbound {
    action   = "ACCEPT"
    label    = "allowed-ips-for-outbound"
    protocol = "TCP"
    ports    = "30093"
    ipv4     = concat(var.settings.dataflow.outbound.allowedIps.ipv4, [ "${jsondecode(data.http.myIp.response_body).ip}/32" ])
    ipv6     = concat(var.settings.dataflow.outbound.allowedIps.ipv6, [ "::1/128" ])
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

  # Akamai firewall compliance.
  inbound {
    action   = "ACCEPT"
    label    = "allow-akamai-ips"
    protocol = "TCP"
    ports    = "22,443"
    ipv4     = [
      "139.144.212.168/31",
      "172.232.23.164/31",
      "172.236.119.4/30",
      "172.234.160.4/30",
      "172.236.94.4/30"
    ]
    ipv6     = [
      "2600:3c06::f03c:94ff:febe:162f/128",
      "2600:3c06::f03c:94ff:febe:16ff/128",
      "2600:3c06::f03c:94ff:febe:16c5/128",
      "2600:3c07::f03c:94ff:febe:16e6/128",
      "2600:3c07::f03c:94ff:febe:168c/128",
      "2600:3c07::f03c:94ff:febe:16de/128",
      "2600:3c08::f03c:94ff:febe:16e9/128",
      "2600:3c08::f03c:94ff:febe:1655/128",
      "2600:3c08::f03c:94ff:febe:16fd/128"
    ]
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

resource "linode_firewall" "clusterNodeBalancers" {
  label           = "${var.settings.general.identifier}-cnb-fw"
  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"

  nodebalancers = [ linode_nodebalancer.inbound.id ]

  # Allow inbound traffic.
  inbound {
    action   = "ACCEPT"
    label    = "allowed-ips-for-inbound"
    protocol = "TCP"
    ports    = "443"
    ipv4     = concat(var.settings.dataflow.inbound.allowedIps.ipv4, [ "${jsondecode(data.http.myIp.response_body).ip}/32" ])
    ipv6     = concat(var.settings.dataflow.inbound.allowedIps.ipv6, [ "::1/128" ])
  }
}
