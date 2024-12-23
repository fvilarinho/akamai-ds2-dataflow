# Setup of the stack.
resource "null_resource" "stackSetup" {
  triggers = {
    always_run = timestamp()
  }

  # Namespaces.
  provisioner "file" {
    connection {
      host        = linode_instance.clusterManager.ip_address
      private_key = chomp(file("~/.ssh/id_rsa"))
    }

    source      = local_file.namespaces.filename
    destination = "/root/namespaces.yaml"
  }

  # Certificate Issuer.
  provisioner "file" {
    connection {
      host        = linode_instance.clusterManager.ip_address
      private_key = chomp(file("~/.ssh/id_rsa"))
    }

    source      = local_file.certIssuer.filename
    destination = "/root/certissuer.yaml"
  }

  # Secrets.
  provisioner "file" {
    connection {
      host        = linode_instance.clusterManager.ip_address
      private_key = chomp(file("~/.ssh/id_rsa"))
    }

    source     = local_file.secrets.filename
    destination = "/root/secrets.yaml"
  }

  # Settings.
  provisioner "file" {
    connection {
      host        = linode_instance.clusterManager.ip_address
      private_key = chomp(file("~/.ssh/id_rsa"))
    }

    source      = local_file.configmaps.filename
    destination = "/root/configmaps.yaml"
  }

  # Containers.
  provisioner "file" {
    connection {
      host        = linode_instance.clusterManager.ip_address
      private_key = chomp(file("~/.ssh/id_rsa"))
    }

    source      = local_file.deployments.filename
    destination = "/root/deployments.yaml"
  }

  # Exposed ports.
  provisioner "file" {
    connection {
      host        = linode_instance.clusterManager.ip_address
      private_key = chomp(file("~/.ssh/id_rsa"))
    }

    source      = local_file.services.filename
    destination = "/root/services.yaml"
  }

  # Ingress.
  provisioner "file" {
    connection {
      host        = linode_instance.clusterManager.ip_address
      private_key = chomp(file("~/.ssh/id_rsa"))
    }

    source      = local_file.ingress.filename
    destination = "/root/ingress.yaml"
  }

  # Stack install script.
  provisioner "file" {
    connection {
      host        = linode_instance.clusterManager.ip_address
      private_key = chomp(file("~/.ssh/id_rsa"))
    }

    source      = abspath(pathexpand("./applyStack.sh"))
    destination = "/root/applyStack.sh"
  }

  depends_on = [
    null_resource.clusterManagerSetup,
    null_resource.clusterWorkerSetup,
    local_file.namespaces,
    local_file.certIssuer,
    local_file.secrets,
    local_file.configmaps,
    local_file.deployments,
    local_file.services,
    local_file.ingress
  ]
}

# Applies the stack in the cluster.
resource "null_resource" "applyStack" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "remote-exec" {
    connection {
      host        = linode_instance.clusterManager.ip_address
      private_key = chomp(file("~/.ssh/id_rsa"))
    }

    inline = [
      "chmod +x *.sh",
      "./applyStack.sh"
    ]
  }

  depends_on = [ null_resource.stackSetup ]
}