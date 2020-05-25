# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

# Protocols are specified as protocol numbers.
# https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml

locals {
  all_protocols    = "all"
  ad_names         = data.template_file.ad_names.*.rendered
  anywhere         = "0.0.0.0/0"
  ssh_port         = 22
  tcp_protocol     = 6
  operator_image_id = var.operator_image_id == "Oracle" ? data.oci_core_images.oracle_images.images.0.id : var.operator_image_id
  vcn_cidr         = data.oci_core_vcn.vcn.cidr_block
}
