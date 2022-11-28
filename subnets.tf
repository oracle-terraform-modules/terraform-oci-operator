# Copyright 2017, 2022 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

resource "oci_core_subnet" "operator" {
  cidr_block                 = local.operator_subnet
  compartment_id             = var.compartment_id
  display_name               = var.label_prefix == "none" ? "operator" : "${var.label_prefix}-operator"
  dns_label                  = var.assign_dns ? "operator" : null
  freeform_tags              = var.freeform_tags
  prohibit_public_ip_on_vnic = true
  route_table_id             = var.nat_route_id
  security_list_ids          = [oci_core_security_list.operator.id]
  vcn_id                     = var.vcn_id

  lifecycle {
    ignore_changes = [dns_label, freeform_tags]
  }
}
