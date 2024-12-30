# Outbound node balancer, used to balance the traffic of external Apache Kafka consumers.
resource "linode_nodebalancer" "outbound" {
  label  = "${var.settings.general.identifier}-outbound"
  tags   = var.settings.general.tags
  region = var.settings.cluster.region
}

resource "linode_nodebalancer_config" "outbound" {
  nodebalancer_id = linode_nodebalancer.outbound.id
  port            = 9092
  protocol        = "tcp"
  check           = "connection"
  check_interval  = 15
  check_attempts  = 3
  check_timeout   = 5
  stickiness      = "table"
  algorithm       = "source"

  depends_on = [ linode_nodebalancer.outbound ]
}

# Manager node for outbound.
resource "linode_nodebalancer_node" "outboundManager" {
  nodebalancer_id = linode_nodebalancer.outbound.id
  config_id       = linode_nodebalancer_config.outbound.id
  label           = "outbound-manager"
  address         = "${linode_instance.clusterManager.private_ip_address}:30093"
  weight          = (100 / var.settings.cluster.nodes.count)

  lifecycle {
    replace_triggered_by = [ linode_instance.clusterManager.id ]
  }

  depends_on = [
    linode_nodebalancer.outbound,
    linode_nodebalancer_config.outbound,
    linode_instance.clusterManager
  ]
}

# Worker nodes for outbound.
resource "linode_nodebalancer_node" "outboundWorker" {
  count           = var.settings.cluster.nodes.count - 1
  nodebalancer_id = linode_nodebalancer.outbound.id
  config_id       = linode_nodebalancer_config.outbound.id
  label           = "outbound-worker${count.index}"
  address         = "${linode_instance.clusterWorker[count.index].private_ip_address}:30093"
  weight          = (100 / var.settings.cluster.nodes.count)

  lifecycle {
    replace_triggered_by = [ linode_instance.clusterWorker[count.index].id ]
  }

  depends_on = [
    linode_nodebalancer.outbound,
    linode_nodebalancer_config.outbound,
    linode_instance.clusterWorker
  ]
}

# Inbound node balancer, used to balance the traffic of external HTTPs clients.
resource "linode_nodebalancer" "inbound" {
  label  = "${var.settings.general.identifier}-inbound"
  tags   = var.settings.general.tags
  region = var.settings.cluster.region
}

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

# Fetches the inbound port to be configured in the node balancer.
data "external" "inboundPort" {
  program = [
    abspath(pathexpand("./inboundPort.sh")),
    local.kubeconfigFilename
  ]

  depends_on = [
    linode_instance.clusterManager,
    null_resource.clusterManagerSetup,
    null_resource.downloadKubeconfig
  ]
}

# Manager node for inbound.
resource "linode_nodebalancer_node" "inboundManager" {
  nodebalancer_id = linode_nodebalancer.inbound.id
  config_id       = linode_nodebalancer_config.inbound.id
  label           = "inbound-manager"
  address         = "${linode_instance.clusterManager.private_ip_address}:${data.external.inboundPort.result.port}"
  weight          = (100 / var.settings.cluster.nodes.count)

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

# Worker nodes for inbound.
resource "linode_nodebalancer_node" "inboundWorker" {
  count           = var.settings.cluster.nodes.count - 1
  nodebalancer_id = linode_nodebalancer.inbound.id
  config_id       = linode_nodebalancer_config.inbound.id
  label           = "inbound-worker${count.index}"
  address         = "${linode_instance.clusterWorker[count.index].private_ip_address}:${data.external.inboundPort.result.port}"
  weight          = (100 / var.settings.cluster.nodes.count)

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