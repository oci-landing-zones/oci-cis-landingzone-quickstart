variable "compartment_id" {
  type        = string
  description = "The default compartment OCID to use for resources (unless otherwise specified)."
  default     = ""
} 

variable "tag_namespace_name" {
  type        = string
  description = "The tag namespace name"
  default     = ""
}  

variable "tag_namespace_description" {
  type        = string
  description = "The tag namespace description"
  default     = ""
}

variable "is_namespace_retired" {
  type        = string
  description = "Whether or not the namespace is retired"
  default     = false
}

variable "tags" {
  type = map(object({
    description  = string,
    is_cost_tracking = bool,
    is_retired = bool,
    default_value = string,
    is_default_required = bool
  }))
}    