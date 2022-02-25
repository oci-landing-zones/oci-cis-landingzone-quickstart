variable "compartment_id" {
  type        = string
  description = "The default compartment OCID where Cloud Guard is enabled."
}

variable "reporting_region" {
  type        = string
  description = "Cloud Guard reporting region."
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

variable "default_target" {
  type        = object({name=string, type=string, id=string})
  description = "The default Cloud Guard target."
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
