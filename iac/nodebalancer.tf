# Definition of the inbound node balancer hostname.
resource "linode_nodebalancer" "inbound" {
  label  = "${var.settings.general.identifier}-inbound"
  tags   = var.settings.general.tags
  region = var.settings.cluster.region
}

# Definition of the inbound node balancer configuration.
resource "linode_nodebalancer_config" "inbound" {
  nodebalancer_id = linode_nodebalancer.inbound.id
  port            = 443
  protocol        = "tcp"
  check           = "connection"
  check_interval  = 15
  check_attempts  = 3
  check_timeout   = 5
  stickiness      = "table"
  algorithm       = "source"

  depends_on = [ linode_nodebalancer.inbound ]
}

# Fetches the inbound port to be used in the node balancer configuration.
data "external" "inboundPort" {
  program = [
    abspath(pathexpand("./fetchInboundPort.sh")),
    local.kubeconfigFilename
  ]

  depends_on = [
    linode_instance.clusterManager,
    null_resource.clusterManagerSetup,
    null_resource.downloadKubeconfig,
    null_resource.applyStack
  ]
}

# Adds the manager node in the node balancer.
resource "linode_nodebalancer_node" "inboundManager" {
  nodebalancer_id = linode_nodebalancer.inbound.id
  config_id       = linode_nodebalancer_config.inbound.id
  label           = "inbound-manager"
  address         = "${linode_instance.clusterManager.private_ip_address}:${data.external.inboundPort.result.port}"
  weight          = floor(100 / var.settings.cluster.nodes.count)

  lifecycle {
    replace_triggered_by = [ linode_instance.clusterManager.id ]
  }

  depends_on = [
    linode_nodebalancer.inbound,
    linode_nodebalancer_config.inbound,
    linode_instance.clusterManager,
    data.external.inboundPort
  ]
}

# Adds the worker nodes in the node balancer.
resource "linode_nodebalancer_node" "inboundWorker" {
  count           = var.settings.cluster.nodes.count - 1
  nodebalancer_id = linode_nodebalancer.inbound.id
  config_id       = linode_nodebalancer_config.inbound.id
  label           = "inbound-worker${count.index}"
  address         = "${linode_instance.clusterWorker[count.index].private_ip_address}:${data.external.inboundPort.result.port}"
  weight          = floor(100 / var.settings.cluster.nodes.count)

  lifecycle {
    replace_triggered_by = [ linode_instance.clusterWorker[count.index].id ]
  }

  depends_on = [
    linode_nodebalancer.inbound,
    linode_nodebalancer_config.inbound,
    linode_instance.clusterWorker,
    data.external.inboundPort
  ]
}