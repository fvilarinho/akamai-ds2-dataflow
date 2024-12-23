variable "settings" {
  default = {
    general = {
      email = "<email>"
      token = "<token>"
    }

    cluster = {
      identifier = "akamai-ds2-dataflow"
      tags       = [ "demo" ]
      region     = "<region>"

      nodes = {
        type  = "<type>"
        count = 1
      }

      allowedIps = {
        ipv4 = [ "0.0.0.0/0" ]
        ipv6 = [ "::/0" ]
      }
    }

    dataflow = {
      inbound = {
        identifier = "rawlogs"

        auth = {
          user     = "<user>"
          password = "<password>"
        }

        storage = {
          size = 10
        }
      }

      outbound = {
        identifier = "processedlogs"

        auth = {
          user      = "<user>"
          password  = "<password>"
          accessKey = "<accessKey>"
          secretKey = "<secretKey>"
        }

        storage = {
          bucket            = "<bucket>"
          endpoint          = "<endpoint>"
          path              = "logs/"
          format            = "<gzip|json>"
          aggregationPeriod = "1m"
        }
      }
    }
  }
}