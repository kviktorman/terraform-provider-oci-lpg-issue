variable "gateway_info" {}
variable "target_network" {}
variable "target_compartment" {}

resource "oci_core_local_peering_gateway" "local_peering_gateway" {
    compartment_id = var.target_compartment
    vcn_id = var.target_network.networkOCID
    display_name = var.gateway_info.gatewayName
}

output "vcn_local_peering_gateway_id" {
  value = oci_core_local_peering_gateway.local_peering_gateway.id
}