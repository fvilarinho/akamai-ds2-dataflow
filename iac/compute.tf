locals {
  sshPrivateKeyFilename = abspath(pathexpand("~/.ssh/id_rsa"))
  sshPublicKeyFilename  = abspath(pathexpand("~/.ssh/id_rsa.pub"))
  clusterInstances      = concat([ linode_instance.clusterManager.id ], [ for clusterWorker in linode_instance.clusterWorker : clusterWorker.id ])
}

data "linode_instances" "clusterInstances" {
  filter {
    name   = "id"
    values = local.clusterInstances
  }

  depends_on = [
    linode_instance.clusterManager,
    linode_instance.clusterWorker
  ]
}

# Defines the cluster manager.
resource "linode_instance" "clusterManager" {
  tags            = var.settings.cluster.tags
  label           = "${var.settings.cluster.identifier}-manager"
  region          = var.settings.cluster.region
  type            = var.settings.cluster.nodes.type
  image           = "linode/debian12"
  private_ip      = true
  authorized_keys = [ chomp(file(local.sshPublicKeyFilename)) ]
}

resource "linode_instance" "clusterWorker" {
  count           = (var.settings.cluster.nodes.count - 1)
  tags            = var.settings.cluster.tags
  label           = "${var.settings.cluster.identifier}-worker${count.index}"
  region          = var.settings.cluster.region
  type            = var.settings.cluster.nodes.type
  image           = "linode/debian12"
  private_ip      = true
  authorized_keys = [ chomp(file(local.sshPublicKeyFilename)) ]
}