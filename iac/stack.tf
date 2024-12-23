# Applies the stack in the cluster.
resource "null_resource" "applyStack" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    environment = {
      KUBECONFIG = local.kubeconfigFilename
      NAMESPACE  = var.settings.cluster.identifier
    }

    quiet   = true
    command = "./applyStack.sh"
  }

  depends_on = [
    linode_instance.clusterManager,
    linode_instance.clusterWorker,
    null_resource.clusterManagerSetup,
    null_resource.clusterWorkerSetup,
    null_resource.downloadKubeconfig
  ]
}