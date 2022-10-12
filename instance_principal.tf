# Copyright (c) 2022, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "random_id" "dynamic_group_suffix" {
  keepers = {
    # Generate a new suffix only when variables are changed
    label_prefix = local.dynamic_group_prefix
    tenancy_id   = var.tenancy_id
  }

  byte_length = 8
}

resource "oci_identity_dynamic_group" "operator_group" {
  provider = oci.home

  compartment_id = random_id.dynamic_group_suffix.keepers.tenancy_id
  description    = "dynamic group %{ if var.label_prefix != "none" }with label ${var.label_prefix}%{ endif } to allow operator to invoke services"

  lifecycle {
    ignore_changes = [defined_tags]
  }

  matching_rule = "ALL {instance.id = '${join(",", data.oci_core_instance.operator.*.id)}'}"
  name           = join("-", compact([
    random_id.dynamic_group_suffix.keepers.label_prefix,
    "operator-instance-principal",
    random_id.dynamic_group_suffix.hex
  ]))

  count = var.enable_operator_instance_principal == true ? 1 : 0
}

resource "oci_identity_policy" "operator_group_policy" {
  provider = oci.home

  compartment_id = var.compartment_id
  description    = "policy to allow operator host to call services"
  name           = join("-", compact([ local.dynamic_group_prefix, "operator-instance-principal" ]))
  statements     = ["Allow dynamic-group ${oci_identity_dynamic_group.operator_group[0].name} to manage all-resources in compartment id ${var.compartment_id}"]

  count = var.enable_operator_instance_principal == true ? 1 : 0
}

moved {
  from = oci_identity_policy.enable_operator_instance_principal
  to = oci_identity_policy.operator_group_policy
}

moved {
  from = oci_identity_dynamic_group.enable_operator_instance_principal
  to = oci_identity_dynamic_group.operator_group
}