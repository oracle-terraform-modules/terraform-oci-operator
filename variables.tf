# Copyright (c) 2019, 2021 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# provider parameters

variable "tenancy_id" {
  description = "tenancy id where to create the sources"
  type        = string
  default     = ""
}

# general oci parameters

variable "compartment_id" {
  description = "compartment id where to create all resources"
  type        = string
}

variable "label_prefix" {
  description = "a string that will be prepended to all resources"
  type        = string
  default     = "none"
}

# network parameters

variable "availability_domain" {
  description = "the AD to place the operator host"
  default     = 1
  type        = number
}

variable "nat_route_id" {
  description = "the id of the route table to the nat gateway."
  type        = string
}

variable "netnum" {
  description = "0-based index of the operator subnet when the VCN's CIDR is masked with the corresponding newbit value."
  default     = 33
  type        = number
}

variable "newbits" {
  description = "The difference between the VCN's netmask and the desired operator subnet mask"
  default     = 13
  type        = number
}

variable "nsg_ids" {
  description = "Optional list of network security groups that the operator will be part of"
  type        = list(string)
  default     = []
}

variable "vcn_id" {
  description = "The id of the VCN to use when creating the operator resources."
  type        = string
}

# operator host parameters

variable "freeform_tags" {
  description = "Freeform tags for operator"
  default = {
    access      = "restricted"
    environment = "dev"
    role        = "operator"
  }
  type = map(any)
}

variable "operator_image_id" {
  description = "Provide a custom image id for the operator host or leave as Oracle."
  default     = "Oracle"
  type        = string
}

variable "operator_instance_principal" {
  description = "whether to enable instance_principal on the operator"
  default     = false
  type        = bool
}

variable "operator_os_version" {
  description = "The version of the Oracle Linux to use."
  default     = "8"
  type        = string
}

variable "operator_shape" {
  description = "The shape of the operator instance."
  default = {
    shape = "VM.Standard.E4.Flex", ocpus = 1, memory = 4, boot_volume_size = 50
  }
  type = map(any)
}

variable "operator_state" {
  description = "The target state for the instance. Could be set to RUNNING or STOPPED. (Updatable)"
  default     = "RUNNING"
  type        = string
}

variable "operator_timezone" {
  description = "The preferred timezone for the operator host."
  default     = "Australia/Sydney"
  type        = string
}

variable "ssh_public_key" {
  description = "the content of the ssh public key used to access the operator. set this or the ssh_public_key_path"
  default     = ""
  type        = string
}

variable "ssh_public_key_path" {
  description = "path to the ssh public key used to access the operator. set this or the ssh_public_key"
  default     = ""
  type        = string
}


variable "upgrade_operator" {
  description = "Whether to upgrade the operator host packages after provisioning. It's useful to set this to false during development/testing so the operator is provisioned faster."
  default     = false
  type        = bool
}

# operator notification
variable "enable_operator_notification" {
  description = "Whether to enable ONS notification for the operator host."
  default     = false
  type        = bool
}

variable "operator_notification_endpoint" {
  description = "The subscription notification endpoint. Email address to be notified."
  default     = null
  type        = string
}

variable "operator_notification_protocol" {
  description = "The notification protocol used."
  default     = "EMAIL"
  type        = string
}

variable "operator_notification_topic" {
  description = "The name of the notification topic"
  default     = "operator"
  type        = string
}
