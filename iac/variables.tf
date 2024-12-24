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
      auth = {
        user     = "<user>"
        password = "<password>"
      }

      inbound = {
        identifier = "rawlogs"

        storage = {
          size = 10
        }
      }

      outbound = {
        identifier = "processedlogs"

        storage = {
          accessKey         = "<accessKey>"
          secretKey         = "<secretKey>"
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