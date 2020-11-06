variable "tag_namespace_compartment_id" {
  type        = string
  description = "The default compartment ocid for tag namespace."
  default     = ""
} 

variable "tag_defaults_compartment_id" {
  type        = string
  description = "The default compartment ocid for tag defaults."
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

variable "force" {  
  type        = bool
  description = "Forces tag defaults creation even if tag defaults for tags in Oracle-Tags namespace exists."
  default     = false
}

variable "tags" {
  type = map(object({
    tag_description         = string,
    tag_is_cost_tracking    = bool,
    tag_is_retired          = bool,
    tag_default_value       = string,
    tag_default_is_required = bool
  }))
}    