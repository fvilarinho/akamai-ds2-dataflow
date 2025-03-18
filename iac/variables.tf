# Define the Akamai Connected Cloud credentials.
variable "credentials" {
  default = {
    # Akamai Cloud Computing credentials.
    linode = {
      token = "<token>"
    }

    # Akamai Intelligent Platform credentials.
    edgegrid = {
      accountKey   = "<account>"
      host         = "<host>"
      accessToken  = "<accessToken>"
      clientToken  = "<clientToken>"
      clientSecret = "<clientSecret>"
    }
  }
}

# Defines the stack settings.
variable "settings" {
  default = {
    # General attributes.
    general = {
      identifier = "akamai-ds2-dataflow" # Identifier of the stack.
      tags       = [ "demo", "datastream", "kafka" ] # Tags to group the provisioned resources of the stack.
      email      = "<email>" # Email to be used in the provisioning of the TLS certificate.
      domain     = "<domain>" # Domain to be used in the provisioning of the TLS certificate an DNS entries.
      contract   = "<contract>" # Contract to be used in the provisioning of the CDN configuration.
      group      = "<group>" # Group to be used in the provisioning of the CDN configuration.
      product    = "<product>" # Product to be used in the provisioning of the CDN configuration.
    }

    # Cluster attributes.
    cluster = {
      region = "<region>" # Region to be used in the provisioning of the infrastructure.

      nodes = {
        type  = "<type>" # Compute instance type.
        count = 1 # Number of instances.
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
        identifier = "raw" # Topic identifier.

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

      # Converter (Parsing and filtering) attributes.
      converter = {
        count = 1 # Number of instances.

        # Filter list the contains the rules.
        filters = [
          {
            fieldName = "<fieldName>"
            regex     = "<regex>"
            include   = false
          }
        ],

        # Number of threads for processing.
        workers = 10
      }

      # Outbound attributes.
      outbound = {
        identifier = "processed" # Topic identifier.
        count = 1

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
          bucket            = "<bucket>" # Bucket name.
          region            = "<region>" # Region identifier.
          path              = "logs/" # Path to store the logs.
          format            = "<gzip|json>" # Format of the logs.
          aggregationPeriod = "1m" # Aggregation period.
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