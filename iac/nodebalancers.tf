resource "linode_nodebalancer" "outbound" {
  label  = "${var.settings.general.identifier}-outbound"
  tags   = var.settings.general.tags
  region = var.settings.cluster.region
}

resource "linode_nodebalancer_config" "outbound" {
  nodebalancer_id = linode_nodebalancer.outbound.id
  port            = 30093
  protocol        = "tcp"
  proxy_protocol  = "v2"
  check           = "connection"
  check_interval  = 5
  check_attempts  = 2
  check_timeout   = 3
  stickiness      = "table"
  algorithm       = "roundrobin"

  depends_on = [ linode_nodebalancer.outbound ]
}

resource "linode_nodebalancer_node" "outboundManager" {
  nodebalancer_id = linode_nodebalancer.outbound.id
  config_id       = linode_nodebalancer_config.outbound.id
  label           = linode_instance.clusterManager.label
  address         = "${linode_instance.clusterManager.private_ip_address}:30093"
  weight          = (100 / var.settings.cluster.nodes.count)

  depends_on = [
    linode_instance.clusterManager,
    linode_nodebalancer.outbound,
    linode_nodebalancer_config.outbound
  ]
}

resource "linode_nodebalancer_node" "outboundWorker" {
  count           = var.settings.cluster.nodes.count - 1
  nodebalancer_id = linode_nodebalancer.outbound.id
  config_id       = linode_nodebalancer_config.outbound.id
  label           = linode_instance.clusterWorker[count.index].label
  address         = "${linode_instance.clusterWorker[count.index].private_ip_address}:30093"
  weight          = (100 / var.settings.cluster.nodes.count)

  depends_on = [
    linode_instance.clusterWorker,
    linode_nodebalancer.outbound,
    linode_nodebalancer_config.outbound
  ]
}