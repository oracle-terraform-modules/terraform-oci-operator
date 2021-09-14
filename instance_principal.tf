# Copyright 2017, 2021 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "oci_identity_dynamic_group" "enable_operator_instance_principal" {
  provider = oci.home

  compartment_id = var.tenancy_id
  description    = var.label_prefix == "none" ? "dynamic group to allow operator instance to invoke services" : "dynamic group with label ${var.label_prefix} to allow operator to invoke services"

  lifecycle {
    ignore_changes = [name, defined_tags]
  }

  matching_rule = "ALL {instance.id = '${join(",", data.oci_core_instance.operator.*.id)}'}"
  name          = "operator-instance-principal-${substr(uuid(), 0, 8)}"

  count = var.enable_operator_instance_principal == true ? 1 : 0
}

resource "oci_identity_policy" "enable_operator_instance_principal" {
  provider = oci.home

  compartment_id = var.compartment_id
  description    = "policy to allow operator host to call services"
  name           = var.label_prefix == "none" ? "operator-instance-principal" : "${var.label_prefix}-operator-instance-principal"
  statements     = ["Allow dynamic-group ${oci_identity_dynamic_group.enable_operator_instance_principal[0].name} to manage all-resources in compartment id ${var.compartment_id}"]

  count = var.enable_operator_instance_principal == true ? 1 : 0
}
