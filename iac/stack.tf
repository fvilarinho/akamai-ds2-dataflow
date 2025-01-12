# Applies the stack in the cluster.
resource "null_resource" "applyStack" {
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
    local_file.configmaps,
    local_file.secrets,
    local_file.services,
    local_file.deployments,
    local_file.ingress
  ]
}