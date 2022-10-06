# Copyright (c) 2022, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

# Protocols are specified as protocol numbers.
# https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml

locals {
  all_protocols = "all"

  anywhere = "0.0.0.0/0"

  dynamic_group_prefix = (var.label_prefix == "none") ? "" : "${var.label_prefix}"

  operator_image_id = var.operator_image_id == "Oracle" ? data.oci_core_images.oracle_images[0].images.0.id : var.operator_image_id

  operator_subnet = cidrsubnet(local.vcn_cidr, var.newbits, var.netnum) 
  operator_template = "${path.module}/cloudinit/operator.template.yaml"

  operator_script_template = base64gzip(
    templatefile("${path.module}/scripts/operator.template.sh",
      {
        ol = var.operator_os_version
      }
    )
  )

  osn = lookup(data.oci_core_services.all_oci_services.services[0], "cidr_block")

  ssh_port = 22

  tcp_protocol = 6

  # we expect the operator to be in the first cidr block in the list of cidr blocks
  vcn_cidr = element(data.oci_core_vcn.vcn.cidr_blocks, 0)
}
