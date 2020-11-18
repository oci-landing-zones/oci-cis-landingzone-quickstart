variable "compartment_id" {
  type        = string
  description = "The default compartment OCID to use for resources (unless otherwise specified)."
  default     = ""
}

variable "reporting_region" {
  type        = string
  description = "Cloud Guard reporting region."
  default     = ""
}

variable "status" {
  type        = string
  description = "Cloud Guard status."
  default     = "ENABLED"
}

variable "self_manage_resources" {
  type        = bool
  description = "Whether or not to self manage resources."
  default     = false
}

variable "service_label" {
  type        = string
  description = "The service label."
  default     = ""
}