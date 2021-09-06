# Copyright 2017, 2021 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

data "oci_core_services" "all_oci_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

data "oci_identity_availability_domain" "ad" {
  compartment_id = var.tenancy_id

  ad_number = var.availability_domain
}

data "oci_identity_tenancy" "tenancy" {
  tenancy_id = var.tenancy_id
}

data "oci_core_vcn" "vcn" {
  vcn_id = var.vcn_id
}

data "oci_core_images" "oracle_images" {
  compartment_id           = var.compartment_id
  operating_system         = "Oracle Linux"
  operating_system_version = var.operator_os_version
  shape                    = lookup(var.operator_shape, "shape", "VM.Standard.E4.Flex")
  sort_by                  = "TIMECREATED"

  count = var.operator_image_id == "Oracle" ? 1 : 0
}

# cloud init for operator
data "cloudinit_config" "operator" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "operator.yaml"
    content_type = "text/cloud-config"
    content = templatefile(
      local.operator_template, {
        operator_sh_content = local.operator_script_template,
        operator_timezone   = var.operator_timezone,
        upgrade_operator    = var.upgrade_operator,
      }
    )
  }
}

# Gets a list of VNIC attachments on the operator instance
data "oci_core_vnic_attachments" "operator_vnics_attachments" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment_id
  depends_on          = [oci_core_instance.operator]
  instance_id         = oci_core_instance.operator.id
}

# Gets the OCID of the first (default) VNIC on the operator instance
data "oci_core_vnic" "operator_vnic" {
  depends_on = [oci_core_instance.operator]
  vnic_id    = lookup(data.oci_core_vnic_attachments.operator_vnics_attachments.vnic_attachments[0], "vnic_id")
}

data "oci_core_instance" "operator" {
  depends_on  = [oci_core_instance.operator]
  instance_id = oci_core_instance.operator.id
}
