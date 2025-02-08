# Creates the outbound storage if the credentials and endpoints are not specified.
resource "linode_object_storage_bucket" "outbound" {
  count  = ((length(var.settings.dataflow.outbound.storage.accessKey) == 0 || length(var.settings.dataflow.outbound.storage.secretKey) == 0 || length(var.settings.dataflow.outbound.storage.endpoint) == 0) ? 1 : 0)
  label  = var.settings.dataflow.outbound.storage.bucket
  region = var.settings.dataflow.outbound.storage.region
}

resource "linode_object_storage_key" "outbound" {
  count = ((length(var.settings.dataflow.outbound.storage.accessKey) == 0 || length(var.settings.dataflow.outbound.storage.secretKey) == 0 || length(var.settings.dataflow.outbound.storage.endpoint) == 0) ? 1 : 0)
  label = var.settings.dataflow.outbound.storage.bucket

  bucket_access {
    bucket_name = var.settings.dataflow.outbound.storage.bucket
    region      = var.settings.dataflow.outbound.storage.region
    permissions = "read_write"
  }

  depends_on = [ linode_object_storage_bucket.outbound ]
}