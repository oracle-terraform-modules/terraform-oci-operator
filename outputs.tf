# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

output "operator_private_ip" {
  value = join(",", data.oci_core_vnic.operator_vnic.*.private_ip_address)
}