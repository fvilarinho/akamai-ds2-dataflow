# Defines the stack settings.
variable "settings" {
  default = {
    # General attributes.
    general = {
      identifier = "akamai-ds2-dataflow" # Identifier of the stack.
      tags       = [ "demo" ] # Tags to group the provisioned resources of the stack.
      email      = "<email>" # Email used in the provisioning of the TLS certificate used by the stack.
    }

    # Cluster attributes.
    cluster = {
      region = "<region>" # Region to be used in the provisioning.

      nodes = {
        type  = "<type>" # Compute instance type.
        count = 1 # Number of compute instances.
      }
    }

    # Dataflow attributes.
    dataflow = {
      # Authentication attributes.
      auth = {
        user     = "<user>"
        password = "<password>"
      }

      # Inbound attributes.
      inbound = {
        identifier = "rawlogs" # Topic identifier.

        # Storage attributes.
        storage = {
          size = 10 # In GB.
        }

        # Firewall attributes.
        allowedIps = {
          ipv4 = [ "0.0.0.0/0" ]
          ipv6 = [ "::/0" ]
        }
      }

      # Outbound attributes.
      outbound = {
        identifier = "processedlogs" # Topic identifier.

        # S3-Compliant Storage attributes.
        storage = {
          accessKey         = "<accessKey>"
          secretKey         = "<secretKey>"
          bucket            = "<bucket>"
          endpoint          = "<endpoint>"
          path              = "logs/"
          format            = "<gzip|json>"
          aggregationPeriod = "1m"
        }

        # Firewall attributes.
        allowedIps = {
          ipv4 = [ "0.0.0.0/0" ]
          ipv6 = [ "::/0" ]
        }
      }
    }
  }
}