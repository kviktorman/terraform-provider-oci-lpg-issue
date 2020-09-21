variable "network_configuration" {}
variable "target_compartment" {}

# creates the virtual cloud network
resource "oci_core_virtual_network" "cloud_network" {
  cidr_block     = var.network_configuration.networkCIDR
  compartment_id = var.target_compartment
  display_name   = var.network_configuration.networkDisplayName
  dns_label      = var.network_configuration.labelForDNS
}

# creates the subnets of the virutal cloud network
resource "oci_core_subnet" "cloud_network_subnet" {
  for_each = { for setting in var.network_configuration.subnets : setting.subnetDisplayName => setting }

  compartment_id      = var.target_compartment
  vcn_id              = oci_core_virtual_network.cloud_network.id
  cidr_block          = each.value.subnetCIDR
  display_name        = each.value.subnetDisplayName
  availability_domain = each.value.subnetAvailabilityZone
  dns_label           = each.value.labelForDNS
}

# get the virtual network with the populated subnets
data "oci_core_subnets" "cloud_network_data" {
  compartment_id = var.target_compartment
  vcn_id         = oci_core_virtual_network.cloud_network.id

  # wait until the subents are created
  depends_on = [oci_core_subnet.cloud_network_subnet]
}

# return the created network details
output "cloud_network_details" {
  value = {
    networkIdentifier = oci_core_virtual_network.cloud_network.display_name
    networkOCID       = data.oci_core_subnets.cloud_network_data.vcn_id,

    # query subnet data
    subnetDetails = [
      for subnet in data.oci_core_subnets.cloud_network_data.subnets : {
        id                 = subnet.id
        availabilityDomain = subnet.availability_domain
    }]
  }
}
