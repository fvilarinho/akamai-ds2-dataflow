# Terraform definition.
terraform {
  # Required providers.
  required_providers {
    linode = {
      source = "linode/linode"
      version = "2.34.0"
    }

    null = {
      source = "hashicorp/null"
      version = "3.2.3"
    }

    random = {
      source = "hashicorp/random"
      version = "3.6.3"
    }
  }
}

# Akamai Cloud Computing provider definition.
provider "linode" {
  token = var.linodeToken
}