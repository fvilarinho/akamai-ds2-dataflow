# Applies the stack in the cluster.
resource "null_resource" "applyStack" {
  # Always execute.
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    environment = {
      KUBECONFIG = local.kubeconfigFilename
      NAMESPACE  = var.settings.general.identifier
    }

    quiet   = true
    command = abspath(pathexpand("./applyStack.sh"))
  }

  depends_on = [
    linode_instance.clusterManager,
    linode_instance.clusterWorker,
    null_resource.clusterManagerSetup,
    null_resource.clusterWorkerSetup,
    null_resource.downloadKubeconfig,
    local_file.namespaces,
    local_file.certIssuer,
    local_file.configMaps,
    local_file.secrets,
    local_file.services,
    local_file.deployments,
    local_file.ingress,
    linode_nodebalancer.inbound,
    linode_nodebalancer_config.inbound,
    linode_nodebalancer_node.inboundManager,
    linode_nodebalancer_node.inboundWorker,
    linode_nodebalancer_config.secureInbound,
    linode_nodebalancer_node.secureInboundManager,
    linode_nodebalancer_node.secureInboundWorker
  ]
}