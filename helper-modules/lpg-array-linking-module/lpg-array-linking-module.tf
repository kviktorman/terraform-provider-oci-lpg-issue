variable "gateway_info" {}
variable "target_network" {}
variable "target_compartment" {}
variable "available_lpg_list" {}

resource "oci_core_local_peering_gateway" "local_peering_gateway_array" {
    for_each = { for setting in var.gateway_info : setting.gatewayName => setting } 
  
    compartment_id = var.target_compartment
    vcn_id = var.target_network.networkOCID
    display_name = each.value.gatewayName
    peer_id = var.available_lpg_list[each.value.targetGatewayName].gatewayId
}
