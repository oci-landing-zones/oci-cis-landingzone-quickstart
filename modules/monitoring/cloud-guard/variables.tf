variable "compartment_id" {
  type        = string
  description = "The default compartment OCID where Cloud Guard is enabled."
}

variable "reporting_region" {
  type        = string
  description = "Cloud Guard reporting region."
}

variable "enable_cloud_guard" {
  type        = bool
  description = "Whether to enable Cloud Guard service."
  default     = true
}

variable "self_manage_resources" {
  type        = bool
  description = "Whether to self manage resources."
  default     = false
}

variable "enable_target" {
  description = "Whether to enable a Cloud Guard target."
  type = bool
  default = true
}

variable "target_type" {
  description = "The Cloud Guard target type."
  type        = string
  default     = "COMPARTMENT"
}

variable "target_id" {
  description = "The Cloud Guard target ocid."
  type        = string
}

variable "target_name" {
  description = "The Cloud Guard target name."
  type        = string
}

variable "defined_tags" {
  type        = map(string)
  description = "Map of key-value pairs of defined tags. (Optional)"
  default     = null
}

variable "freeform_tags" {
  type        = map(string)
  description = "Map of key-value pairs of freeform tags. (Optional)"
  default     = null
}
