# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# create a home region provider for identity operations
provider "oci" {
  alias            = "home"
  fingerprint      = var.api_fingerprint
  private_key_path = var.api_private_key_path
  region           = lookup(data.oci_identity_regions.home_region.regions[0], "name")
  tenancy_ocid     = var.tenancy_id
  user_ocid        = var.user_id
}

resource "oci_identity_dynamic_group" "operator_instance_principal" {
  provider = oci.home

  compartment_id = var.tenancy_id
  description    = "dynamic group to allow instances to call services for 1 operator"
  
  lifecycle {
    ignore_changes = [name]
  }

  matching_rule  = "ALL {instance.id = '${join(",", data.oci_core_instance.operator.*.id)}'}"
  name           = var.label_prefix == "none" ? "operator-instance-principal-${substr(uuid(),0,8)}" : "${var.label_prefix}-operator-instance-principal-${substr(uuid(),0,8)}"

  count = var.operator_enabled == true && var.operator_instance_principal == true ? 1 : 0
}

resource "oci_identity_policy" "operator_instance_principal" {
  provider = oci.home

  compartment_id = var.compartment_id
  description    = "policy to allow operator host to call services"
  name           = var.label_prefix == "none" ? "operator-instance-principal" : "${var.label_prefix}-operator-instance-principal"
  statements     = ["Allow dynamic-group ${oci_identity_dynamic_group.operator_instance_principal[0].name} to manage all-resources in compartment id ${var.compartment_id}"]

  count = var.operator_enabled == true && var.operator_instance_principal == true ? 1 : 0
}
