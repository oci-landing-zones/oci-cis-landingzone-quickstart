variable "tenancy_ocid" {
  type        = string
  description = "Tenancy ID"
  default     = ""
} 
variable "compartment_id" {
  type        = string
  description = "The default compartment OCID to use for resources (unless otherwise specified)."
  default     = ""
} 

variable "service_label" {
  type = string
  description = "Service Label"
  default = ""
}

variable "compartment_name" {
  type        = string
  description = "Compartment anme"
  default     = ""
} 

variable "vault_name" {
  type        = string
  description = "Vault Name"
  default     = ""
} 

variable "vault_type" {
  type        = string
  description = "Vault Type - DEFAULT (Shared)"
  default     = ""
}  
variable "key_display_name" {
  type        = string
  description = "Key Display name"
  default     = ""
}  

variable "key_key_shape_algorithm" {
  type        = string
  description = "Key Algorithm"
  default     = ""
}  

variable "key_key_shape_length" {
  type        = string
  description = "Key Length"
  default     = ""
}  

variable "region" {
  type        = string
  description = "Region"
  default     = ""
}  

variable "defined_tags" {
  type        = map(string)
  default     = {}
}



