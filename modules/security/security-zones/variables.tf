# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

#---------------------------------------------------------------
#--- Cloud Guard Security Zone Recipe variables ----------------
#---------------------------------------------------------------
variable "single_compartment_id" {
  type        = string
  description = "Compartment OCID to create and attach a security zone to a single compartment. If this variable is provide all other compartments_ids will ignored."
  default     = null
}

variable "enclosing_compartment_id" {
  type        = string
  description = "Compartment OCID of the Landing Zone's enclosing compartment.  If this varibale is provided compartment_ids for app, database, network, security, and exadata will be ignored."
  default     = null
}

variable "appdev_compartment_id" {
  type        = string
  description = "Compartment OCID of the Landing Zone's AppDev compartment."
  default     = null
}

variable "database_compartment_id" {
  type        = string
  description = "Compartment OCID of the Landing Zone's Database compartment."
  default     = null
}

variable "exadata_compartment_id" {
  type        = string
  description = "Compartment OCID of the Landing Zone's Exadata compartment."
  default     = null
}

variable "network_compartment_id" {
  type        = string
  description = "Compartment OCID of the Landing Zone's Network compartment."
  default     = null
}

variable "security_compartment_id" {
  type        = string
  description = "Compartment OCID of the Landing Zone's Security compartment."
  default     = null
}

variable "cis_level" {
  type        = string
  description = "CIS OCI Benchmark Level of security zone polices to apply. Default is 1."
  default     = "1"
}

variable "security_policies" {
  type        = list
  description = "List of Security Zone Policies OCIDs which will be merged with CIS security zone policies."
  default     = null 
}

variable "description" {
  type        = string
  description = "Description of the Security Zone and Security Zone recipe it will be appended to the security zone and security recipe name."
  default     = ""
}

variable "defined_tags" {
  type        = map(string)
  description = "Security Zone and Security Zone recipe defined tags."
  default     = null
}

variable "freeform_tags" {
  type        = map(string)
  description = "Security Zone and Security Zone recipe freeform tags."
  default     = null
}