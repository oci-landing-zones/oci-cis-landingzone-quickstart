variable "region" {
  type        = string
  description = "Region"
  default     = ""
} 
variable "compartment_id" {
  type        = string
  description = "The default compartment OCID to use for resources (unless otherwise specified)."
  default     = ""
} 

variable "compartment_name" {
  type        = string
  description = "Compartment Name"
  default     = ""
}  

variable "bucket_name" {
  type        = string
  description = "Bucket Name"
  default     = ""
}  

variable "kms_key_id" {
  type        = string
  description = "KMS Key ID"
  default     = ""
}  