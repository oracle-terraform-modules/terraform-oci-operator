# Copyright 2017, 2021 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

resource "oci_core_instance" "operator" {
  availability_domain = data.oci_identity_availability_domain.ad.name

  agent_config {

    are_all_plugins_disabled = false
    is_management_disabled   = false
    is_monitoring_disabled   = false

    plugins_config {
      desired_state = "ENABLED"
      name          = "Bastion"
    }
  }
  
  compartment_id = var.compartment_id
  freeform_tags  = var.freeform_tags

  create_vnic_details {
    assign_public_ip = false
    display_name     = var.label_prefix == "none" ? "operator-vnic" : "${var.label_prefix}-operator-vnic"
    hostname_label   = var.label_prefix == "none" ? "operator" : "${var.label_prefix}-operator"
    nsg_ids          = concat(var.nsg_ids, [oci_core_network_security_group.operator.id])
    subnet_id        = oci_core_subnet.operator.id
  }

  display_name = var.label_prefix == "none" ? "operator" : "${var.label_prefix}-operator"

  launch_options {
    boot_volume_type = "PARAVIRTUALIZED"
    network_type     = "PARAVIRTUALIZED"
  }

  # prevent the operator from destroying and recreating itself if the image ocid changes 
  lifecycle {
    ignore_changes = [source_details[0].source_id]
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key != "" ? var.ssh_public_key : file(var.ssh_public_key_path)
    user_data           = data.cloudinit_config.operator.rendered
  }

  shape = lookup(var.operator_shape, "shape", "VM.Standard.E4.Flex")

  dynamic "shape_config" {
    for_each = length(regexall("Flex", lookup(var.operator_shape, "shape", "VM.Standard.E4.Flex"))) > 0 ? [1] : []
    content {
      ocpus         = max(1, lookup(var.operator_shape, "ocpus", 1))
      memory_in_gbs = (lookup(var.operator_shape, "memory", 4) / lookup(var.operator_shape, "ocpus", 1)) > 64 ? (lookup(var.operator_shape, "ocpus", 1) * 4) : lookup(var.operator_shape, "memory", 4)
    }
  }

  source_details {
    source_type = "image"
    source_id   = local.operator_image_id
  }

  state = var.operator_state

  timeouts {
    create = "60m"
  }
}
