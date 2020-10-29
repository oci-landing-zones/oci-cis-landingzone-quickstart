variable "tenancy_ocid" {
  description = "The OCID of the tenancy. "
}

variable "compartments" {
  type = map(object({
    description  = string
  }))
}  
