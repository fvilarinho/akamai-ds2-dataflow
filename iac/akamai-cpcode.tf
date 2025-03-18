# Definition of the CP Code used for reporting and billing.
resource "akamai_cp_code" "default" {
  contract_id = var.settings.general.contract
  group_id    = var.settings.general.group
  product_id  = var.settings.general.product
  name        = var.settings.general.identifier
}