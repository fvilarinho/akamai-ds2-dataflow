# Defines the credentials for Akamai EdgeGrid.
provider "akamai" {
  config {
    account_key   = var.credentials.edgegrid.accountKey
    host          = var.credentials.edgegrid.host
    access_token  = var.credentials.edgegrid.accessToken
    client_token  = var.credentials.edgegrid.clientToken
    client_secret = var.credentials.edgegrid.clientSecret
  }
}