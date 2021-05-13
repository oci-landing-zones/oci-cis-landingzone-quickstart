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
