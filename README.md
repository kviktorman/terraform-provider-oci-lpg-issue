# terraform-provider-oci-lpg-issue
Oracle Local Peering Gateway (LPG)  for virtual cloud networks (VCN) seems to have issues when it is created with a for loop. This repository is for providing an example usage so Oracle terraform team can have a look and debug.


The issue is that when you create the local peering gateway manually then everything is working fine. Means that the two LPGs are successfully connected. 

This is not the case for dynamic local peering gateway creation, after the first terraform when everything seems to be good the second terraform run will force destroy the linking on one side which will end up breaking the connection.

The repository has two examples the first is connecting the two VCNs manually , which is currently commented out, the second is the dynamic gateway linking which will go to error.

Note that two VCNs can linked only once, so pay attention that only one connection is active between them.