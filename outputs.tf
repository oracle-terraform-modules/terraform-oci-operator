# Copyright 2017, 2021 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

output "operator_private_ip" {
  value = join(",", data.oci_core_vnic.operator_vnic.*.private_ip_address)
}

output "operator_instance_principal_group_name" {
  value = var.operator_instance_principal == true ? oci_identity_dynamic_group.operator_instance_principal[0].name : null
}

output "operator_subnet_id" {
  value = data.oci_core_instance.operator.subnet_id
}