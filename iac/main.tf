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
  config_path    = abspath(pathexpand("~/.aws/credentials"))
  config_profile = "akamai"
}