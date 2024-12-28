# Required local variables.
locals {
  sshPrivateKeyFilename = abspath(pathexpand("~/.ssh/id_rsa"))
  sshPublicKeyFilename  = abspath(pathexpand("~/.ssh/id_rsa.pub"))
  clusterInstances      = concat([ linode_instance.clusterManager.id ], [ for clusterWorker in linode_instance.clusterWorker : clusterWorker.id ])
}

# Fetches the metadata of the cluster instances.
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
  tags            = var.settings.general.tags
  label           = "${var.settings.general.identifier}-manager"
  region          = var.settings.cluster.region
  type            = var.settings.cluster.nodes.type
  image           = "linode/debian12"
  private_ip      = true
  authorized_keys = [ chomp(file(local.sshPublicKeyFilename)) ]
}

# Defines the cluster workers.
resource "linode_instance" "clusterWorker" {
  count           = (var.settings.cluster.nodes.count - 1)
  tags            = var.settings.general.tags
  label           = "${var.settings.general.identifier}-worker${count.index}"
  region          = var.settings.cluster.region
  type            = var.settings.cluster.nodes.type
  image           = "linode/debian12"
  private_ip      = true
  authorized_keys = [ chomp(file(local.sshPublicKeyFilename)) ]
}