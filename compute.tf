# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

resource "oci_core_instance" "operator" {
  availability_domain = element(local.ad_names, (var.availability_domain - 1))
  compartment_id      = var.compartment_id
  freeform_tags       = var.tags

  create_vnic_details {
    assign_public_ip = false
    display_name     = var.label_prefix == "none" ? "operator-vnic" : "${var.label_prefix}-operator-vnic"
    hostname_label   = var.label_prefix == "none" ? "operator" : "${var.label_prefix}-operator"
    nsg_ids          = var.nsg_ids
    subnet_id        = oci_core_subnet.operator[0].id
  }

  display_name = var.label_prefix == "none" ? "operator" : "${var.label_prefix}-operator"

  # prevent the operator from destroying and recreating itself if the image ocid changes 
  lifecycle {
    ignore_changes = [source_details[0].source_id]
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key != "" ? var.ssh_public_key : file(var.ssh_public_key_path)
    user_data           = data.template_cloudinit_config.operator[0].rendered
  }

  shape = var.operator_shape

  source_details {
    source_type = "image"
    source_id   = local.operator_image_id
  }

  timeouts {
    create = "60m"
  }

  count = var.operator_enabled == true ? 1 : 0
}
