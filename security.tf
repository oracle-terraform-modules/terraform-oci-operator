# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

resource "oci_core_security_list" "operator" {
  compartment_id = var.compartment_id
  display_name   = var.label_prefix == "none" ? "operator" : "${var.label_prefix}-operator"
  freeform_tags  = var.tags

  egress_security_rules {
    protocol    = local.all_protocols
    destination = local.anywhere
  }

  ingress_security_rules {
    # allow ssh
    protocol = local.tcp_protocol
    source   = local.vcn_cidr

    tcp_options {
      min = local.ssh_port
      max = local.ssh_port
    }
  }
  vcn_id = var.vcn_id

  count = var.operator_enabled == true ? 1 : 0
}
