variable "gateway_info" {}
variable "target_network" {}
variable "target_compartment" {}

locals {
  queried_lpg_gateway_list_as_map = { for gateway in data.oci_core_local_peering_gateways.local_gateways_array.local_peering_gateways : gateway.display_name => {
    networkId = gateway.vcn_id,
    networkCompartmentId = gateway.compartment_id,
    gatewayName = gateway.display_name,
    gatewayId = gateway.id
  }}
}

resource "oci_core_local_peering_gateway" "local_peering_gateway_array" {
    for_each = { for setting in var.gateway_info : setting.gatewayName => setting } 
  
    compartment_id = var.target_compartment
    vcn_id = var.target_network.networkOCID
    display_name = each.value.gatewayName
}

data "oci_core_local_peering_gateways" "local_gateways_array" {
    compartment_id = var.target_compartment
    vcn_id = var.target_network.networkOCID
    
    # wait until the vcn LPGs are created
    depends_on = [oci_core_local_peering_gateway.local_peering_gateway_array]
}

output "vcn_local_peering_gateways" {
  value = local.queried_lpg_gateway_list_as_map
}