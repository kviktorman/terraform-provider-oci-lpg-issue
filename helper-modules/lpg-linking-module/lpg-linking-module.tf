variable "gateway_info" {}
variable "target_network" {}
variable "target_compartment" {}
variable "target_vcn_peer_id" {}

resource "oci_core_local_peering_gateway" "local_peering_gateway" {
    compartment_id = var.target_compartment
    vcn_id = var.target_network.networkOCID
    display_name = var.gateway_info.gatewayName
    peer_id = var.target_vcn_peer_id
}

output "vcn_local_peering_gateways" {
  value = oci_core_local_peering_gateway.local_peering_gateway.id
}