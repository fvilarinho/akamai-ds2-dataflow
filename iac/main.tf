# Terraform definition.
terraform {
  # Required providers.
  required_providers {
    linode = {
      source = "linode/linode"
    }

    null = {
      source = "hashicorp/null"
    }

    random = {
      source = "hashicorp/random"
    }
  }
}

# Akamai Cloud Computing provider definition.
provider "linode" {
  token = var.settings.general.token
}