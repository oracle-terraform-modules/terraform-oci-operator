# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

data "oci_identity_availability_domains" "ad_list" {
  compartment_id = var.tenancy_id
}

data "template_file" "ad_names" {
  count    = length(data.oci_identity_availability_domains.ad_list.availability_domains)
  template = lookup(data.oci_identity_availability_domains.ad_list.availability_domains[count.index], "name")
}

data "oci_identity_tenancy" "tenancy" {
  tenancy_id = var.tenancy_id
}

# get the tenancy's home region
data "oci_identity_regions" "home_region" {
  filter {
    name   = "key"
    values = [data.oci_identity_tenancy.tenancy.home_region_key]
  }
}

data "oci_core_vcn" "vcn" {
  vcn_id = var.vcn_id
}

data "template_file" "oracle_template" {
  template = file("${path.module}/scripts/operator.template.sh")

  count = (var.operator_enabled == true && var.operator_image_id == "Oracle") ? 1 : 0
}

data "template_file" "oracle_cloud_init_file" {
  template = file("${path.module}/cloudinit/operator.template.yaml")

  vars = {
    operator_sh_content = base64gzip(data.template_file.oracle_template[0].rendered)
    operator_upgrade    = var.operator_upgrade
    timezone            = var.timezone
  }

  count = (var.operator_enabled == true && var.operator_image_id == "Oracle") ? 1 : 0
}

data "oci_core_images" "oracle_images" {
  compartment_id           = var.compartment_id
  operating_system         = "Oracle Linux"
  shape                    = var.operator_shape
  sort_by                  = "TIMECREATED"
}

# cloud init for operator
data "template_cloudinit_config" "operator" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "operator.yaml"
    content_type = "text/cloud-config"
    content      = data.template_file.oracle_cloud_init_file[0].rendered
  }
  count = var.operator_enabled == true ? 1 : 0
}

# Gets a list of VNIC attachments on the operator instance
data "oci_core_vnic_attachments" "operator_vnics_attachments" {
  availability_domain = element(local.ad_names, (var.availability_domain - 1))
  compartment_id      = var.compartment_id
  depends_on          = [oci_core_instance.operator]
  instance_id         = oci_core_instance.operator[0].id

  count = var.operator_enabled == true ? 1 : 0
}

# Gets the OCID of the first (default) VNIC on the operator instance
data "oci_core_vnic" "operator_vnic" {
  depends_on = [oci_core_instance.operator]
  vnic_id    = lookup(data.oci_core_vnic_attachments.operator_vnics_attachments[0].vnic_attachments[0], "vnic_id")

  count = var.operator_enabled == true ? 1 : 0
}

data "oci_core_instance" "operator" {
  depends_on  = [oci_core_instance.operator]
  instance_id = oci_core_instance.operator[0].id

  count = var.operator_enabled == true ? 1 : 0
}
