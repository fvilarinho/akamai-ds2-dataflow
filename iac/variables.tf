# Define the Akamai Cloud Computing credentials.
variable "linodeToken" {}

# Defines the stack settings.
variable "settings" {
  default = {
    # General attributes.
    general = {
      identifier = "akamai-ds2-dataflow" # Identifier of the stack.
      tags       = [ "demo", "datastream", "kafka" ] # Tags to group the provisioned resources of the stack.
      email      = "<email>" # Email used in the provisioning of the TLS certificate used by the stack.
    }

    # Cluster attributes.
    cluster = {
      region = "<region>" # Region to be used in the provisioning.

      nodes = {
        type  = "<type>" # Compute instance type.
        count = 1 # Number of compute instances.
      }

      # Firewall attributes.
      allowedIps = {
        ipv4 = [ "0.0.0.0/0" ]
        ipv6 = [ "::/0" ]
      }
    }

    # Dataflow attributes.
    dataflow = {
      # Inbound attributes.
      inbound = {
        identifier = "rawlogs" # Topic identifier.

        # Authentication attributes.
        auth = {
          user     = "<user>"
          password = "<password>"
        }

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

      converter = {
        count = 10
        filters = [
          {
            fieldName = "<fieldName>"
            regex     = "<regex>"
            include   = false
          }
        ],
        workers = 100
      }

      # Outbound attributes.
      outbound = {
        identifier = "processedlogs" # Topic identifier.

        # Authentication attributes.
        auth = {
          user     = "<user>"
          password = "<password>"
        }

        # S3-Compliant Storage attributes.
        storage = {
          accessKey         = "<accessKey>" # Leave empty if you want new credentials.
          secretKey         = "<secretKey>" # Leave empty if you want new credentials.
          endpoint          = "<endpoint>" # Leave empty if you want to create a new bucket.
          bucket            = "<bucket>"
          region            = "<region>"
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