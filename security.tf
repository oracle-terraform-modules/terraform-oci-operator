# Copyright 2017, 2021 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

# operator nsg and rule
resource "oci_core_network_security_group" "operator" {
  compartment_id = var.compartment_id
  display_name   = "${var.label_prefix}-operator"
  vcn_id         = var.vcn_id
}

resource "oci_core_network_security_group_security_rule" "operator_egress_anywhere" {
  network_security_group_id = oci_core_network_security_group.operator.id
  description               = "allow operator to egress to anywhere"
  destination               = local.anywhere
  destination_type          = "CIDR_BLOCK"
  direction                 = "EGRESS"
  protocol                  = local.all_protocols
  stateless                 = false

  lifecycle {
    ignore_changes = [direction, protocol, source, source_type, tcp_options]
  }
}

resource "oci_core_network_security_group_security_rule" "operator_egress_osn" {
  network_security_group_id = oci_core_network_security_group.operator.id
  description               = "allow operator to egress to osn"
  destination               = local.osn
  destination_type          = "SERVICE_CIDR_BLOCK"
  direction                 = "EGRESS"
  protocol                  = local.all_protocols
  stateless                 = false

  lifecycle {
    ignore_changes = [direction, protocol, source, source_type, tcp_options]
  }
}

resource "oci_core_network_security_group_security_rule" "operator_ingress" {
  network_security_group_id = oci_core_network_security_group.operator.id
  description               = "allow ssh access to operator from within vcn"
  direction                 = "INGRESS"
  protocol                  = local.tcp_protocol
  source                    = local.vcn_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = local.ssh_port
      max = local.ssh_port
    }
  }

  lifecycle {
    ignore_changes = [direction, protocol, source, source_type, tcp_options]
  }
}

resource "oci_core_security_list" "operator" {
  compartment_id = var.compartment_id
  display_name   = var.label_prefix == "none" ? "operator" : "${var.label_prefix}-operator"
  freeform_tags  = var.tags

  # egress rule to the same subnet to allow users to use OCI Bastion service to connect to the operator
  egress_security_rules {
    protocol    = local.tcp_protocol
    destination = local.operator_subnet

    tcp_options {
      min = local.ssh_port
      max = local.ssh_port
    }
  }

  vcn_id = var.vcn_id
}
