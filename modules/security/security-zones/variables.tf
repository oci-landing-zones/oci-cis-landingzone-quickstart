# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

#---------------------------------------------------------------
#--- Cloud Guard Security Zone Recipe variables ----------------
#---------------------------------------------------------------
variable "sz_target_compartments" {
  type        = map(object({
                  sz_compartment_name  = string
                  sz_compartment_id = string
  }))
  description = "Map of compartment OCIDs and compartment names to create and attach a security zones to. "
  default     = {}
}

variable "cis_level" {
  type        = string
  description = "Determines CIS OCI Benchmark Level of security zone polices to be applied to the compartments. Level 1 is be practical and prudent. Level 2 is intended for environments where security is more critical than manageability and usability."
  default     = "1"
  validation {
     condition     = contains(["1", "2"], upper(var.cis_level))
      error_message = "Validation failed for cis_level: valid values are 1 or 2."
  }
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