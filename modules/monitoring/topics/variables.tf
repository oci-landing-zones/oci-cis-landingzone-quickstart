variable "compartment_id" {
  type        = string
  description = "The default compartment OCID to use for resources (unless otherwise specified)."
  default     = ""
} 

variable "notification_topic_name" {
  type        = string
  description = "The notification topic name."
  default     = ""
} 

variable "notification_topic_description" {
  type        = string
  description = "The notification topic description."
  default     = ""
}

variable "subscription_protocol" {
  type        = string
  description = "The subscription protocol."
  default     = ""
}

variable "subscription_endpoint" {
  type        = string
  description = "The subscription endpoint."
  default     = ""
}