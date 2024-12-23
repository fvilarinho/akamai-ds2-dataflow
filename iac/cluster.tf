locals {
  clusterInstances = concat([ linode_instance.clusterManager.id ], [ for clusterWorker in linode_instance.clusterWorker : clusterWorker.id ])
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

# Defines the default cluster token.
resource "random_string" "clusterToken" {
  length = 15
}

# Defines the cluster manager.
resource "linode_instance" "clusterManager" {
  tags            = var.settings.cluster.tags
  label           = "${var.settings.cluster.identifier}-manager"
  region          = var.settings.cluster.region
  type            = var.settings.cluster.nodes.type
  image           = "linode/debian12"
  private_ip      = true
  authorized_keys = [ chomp(file(abspath(pathexpand("~/.ssh/id_rsa.pub")))) ]
}

resource "null_resource" "clusterManagerSetup" {
  provisioner "remote-exec" {
    connection {
      host = linode_instance.clusterManager.ip_address
      private_key = chomp(file("~/.ssh/id_rsa"))
    }

    inline = [
      "export DEBIAN_FRONTEND=nointeractive",
      "apt update",
      "apt -y upgrade",
      "hostnamectl set-hostname ${linode_instance.clusterManager.label}",
      "apt -y install curl unzip zip dnsutils net-tools htop",
      "export K3S_TOKEN=\"${random_string.clusterToken.result}\"",
      "curl -sfL https://get.k3s.io | sh -"
    ]
  }

  depends_on = [
    random_string.clusterToken,
    linode_instance.clusterManager,
  ]
}

resource "linode_instance" "clusterWorker" {
  count           = (var.settings.cluster.nodes.count - 1)
  tags            = var.settings.cluster.tags
  label           = "${var.settings.cluster.identifier}-worker${count.index}"
  region          = var.settings.cluster.region
  type            = var.settings.cluster.nodes.type
  image           = "linode/debian12"
  private_ip      = true
  authorized_keys = [ chomp(file(abspath(pathexpand("~/.ssh/id_rsa.pub")))) ]
}

resource "null_resource" "clusterWorkerSetup" {
  count = (var.settings.cluster.nodes.count - 1)

  provisioner "remote-exec" {
    connection {
      host = linode_instance.clusterWorker[count.index].ip_address
      private_key = chomp(file("~/.ssh/id_rsa"))
    }

    inline = [
      "export DEBIAN_FRONTEND=nointeractive",
      "apt update",
      "apt -y upgrade",
      "hostnamectl set-hostname ${linode_instance.clusterWorker[count.index].label}",
      "apt -y install curl unzip zip dnsutils net-tools htop",
      "export K3S_TOKEN=\"${random_string.clusterToken.result}\"",
      "export K3S_URL=\"https://${linode_instance.clusterManager.ip_address}:6443\"",
      "curl -sfL https://get.k3s.io | sh -"
    ]
  }

  depends_on = [
    random_string.clusterToken,
    linode_instance.clusterManager,
    null_resource.clusterManagerSetup,
    linode_instance.clusterWorker
  ]
}