locals {
  kubeconfigFilename = abspath(pathexpand("./.kubeconfig"))
}

# Defines the default cluster token.
resource "random_string" "clusterToken" {
  length = 15
}

resource "null_resource" "clusterManagerSetup" {
  provisioner "remote-exec" {
    connection {
      host        = linode_instance.clusterManager.ip_address
      private_key = chomp(file(local.sshPrivateKeyFilename))
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

resource "null_resource" "clusterWorkerSetup" {
  count = (var.settings.cluster.nodes.count - 1)

  provisioner "remote-exec" {
    connection {
      host        = linode_instance.clusterWorker[count.index].ip_address
      private_key = chomp(file(local.sshPrivateKeyFilename))
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

resource "null_resource" "downloadKubeconfig" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    environment = {
      CLUSTER_MANAGER_IP       = linode_instance.clusterManager.ip_address
      SSH_PRIVATE_KEY_FILENAME = local.sshPrivateKeyFilename
      KUBECONFIG_FILENAME      = local.kubeconfigFilename
    }

    quiet   = true
    command = "./downloadKubeconfig.sh"
  }

  depends_on = [
    linode_instance.clusterManager,
    null_resource.clusterManagerSetup
  ]
}