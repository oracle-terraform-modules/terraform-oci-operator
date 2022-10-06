# Copyright (c) 2022, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

output "operator_private_ip" {
  value = join(",", data.oci_core_vnic.operator_vnic.*.private_ip_address)
}

output "operator_instance_principal_group_name" {
  value = var.enable_operator_instance_principal == true ? oci_identity_dynamic_group.operator_group[0].name : null
}

output "operator_subnet_id" {
  value = oci_core_subnet.operator.id
}

output "operator_nsg_id" {
  value = oci_core_network_security_group.operator.id
}
