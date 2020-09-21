variable "oci_provider_tenancy_ocid" {}
variable "oci_provider_region_1" {}
variable "oci_provider_user_ocid" {}
variable "oci_provider_user_fingerprint" {}
variable "oci_provider_user_key_path" {}
variable "oci_provider_target_compartment_ocid" {}
variable "oci_provider_subnet_ad1" { }
variable "oci_provider_subnet_ad2" { }

provider "oci" {
  alias            = "oci-provider-1"
  tenancy_ocid     = var.oci_provider_tenancy_ocid
  region           = var.oci_provider_region_1
  user_ocid        = var.oci_provider_user_ocid
  fingerprint      = var.oci_provider_user_fingerprint
  private_key_path = var.oci_provider_user_key_path
}

locals {
  target_compartment = var.oci_provider_target_compartment_ocid
  subnetAvailabilityZone1 = var.oci_provider_subnet_ad1 
  subnetAvailabilityZone2 = var.oci_provider_subnet_ad2 
  networkA = {
      networkDisplayName = "networkA"
      networkCIDR        = "10.0.0.0/16"
      labelForDNS        = "networkBDNS"
      subnets = [{
          subnetDisplayName      = "VCN-A-subnet-1"
          subnetCIDR             = "10.0.0.0/24"
          subnetAvailabilityZone = local.subnetAvailabilityZone1
          labelForDNS            = "NwAsubnet1DNS"
        }, {
          subnetDisplayName      = "VCN-A-subnet-2"
          subnetCIDR             = "10.0.1.0/24"
          subnetAvailabilityZone = local.subnetAvailabilityZone2
          labelForDNS            = "NwAsubnet2DNS"
        }]
    }
  networkB = {
      networkDisplayName = "networkB"
      networkCIDR        = "192.3.0.0/16"
      labelForDNS        = "networkADNS"
      subnets = [{
          subnetDisplayName      = "VCN-B-subnet-1"
          subnetCIDR             = "192.3.0.0/24"
          subnetAvailabilityZone = local.subnetAvailabilityZone1
          labelForDNS            = "NwBsubnet1DNS"
        }, {
          subnetDisplayName      = "VCN-B-subnet-2"
          subnetCIDR             = "192.3.1.0/24"
          subnetAvailabilityZone = local.subnetAvailabilityZone2
          labelForDNS            = "NwBsubnet2DNS"
        }]
    }
    gatewayFromA = {
      gatewayName = "gatewayToB"
    }
    gatewayFromB = {
      gatewayName = "gatewayToA"
    }
    gatewayArrayFromA = [ {
      gatewayName = "gatewayToB2"
    },{
      gatewayName = "gatewayToC"
    }
    ]
    gatewayArrayFromB = [{
      gatewayName = "gatewayToA2",
      targetGatewayName = "gatewayToB2"
    }]
}

# create networkA
module "networkA" {
  source                      = "./helper-modules/vcn-module"
  providers                   = { oci = oci.oci-provider-1 }
  network_configuration       = local.networkA
  target_compartment = local.target_compartment
}

# create networkB
module "networkB" {
  source                      = "./helper-modules/vcn-module"
  providers                   = { oci = oci.oci-provider-1 }
  network_configuration       = local.networkB
  target_compartment = local.target_compartment
}
/* 
# This part is by setting manually the connection, it works perfectly


# create gateway on A
module "gatewayOnA"  {
  source                      = "./helper-modules/lpg-module"
  providers                   = { oci = oci.oci-provider-1 }
  gateway_info = local.gatewayFromA
  target_network = module.networkA.cloud_network_details
  target_compartment = local.target_compartment
}

# create gateway on B
module "gatewayOnB"  {
  source                      = "./helper-modules/lpg-linking-module"
  providers                   = { oci = oci.oci-provider-1 }
  gateway_info = local.gatewayFromB
  target_network = module.networkB.cloud_network_details
  target_compartment = local.target_compartment
  target_vcn_peer_id = module.gatewayOnA.vcn_local_peering_gateway_id
}*/

module "gatewayArrayOnA" {
  source                      = "./helper-modules/lpg-array-module"
  providers                   = { oci = oci.oci-provider-1 }
  gateway_info = local.gatewayArrayFromA
  target_network = module.networkA.cloud_network_details
  target_compartment = local.target_compartment
}

module "gatewayArrayOnB" {
  source                      = "./helper-modules/lpg-array-linking-module"
  providers                   = { oci = oci.oci-provider-1 }
  gateway_info = local.gatewayArrayFromB
  target_network = module.networkB.cloud_network_details
  target_compartment = local.target_compartment
  available_lpg_list = module.gatewayArrayOnA.vcn_local_peering_gateways
}

output "available_lpg_list" {
  value = module.gatewayArrayOnA.vcn_local_peering_gateways
}