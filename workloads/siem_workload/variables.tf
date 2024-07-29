# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
# ------------------------------------------------------
# ----- Environment
# ------------------------------------------------------
variable "tenancy_ocid" {}
variable "user_ocid" {
  default = ""
}
variable "fingerprint" {
  default = ""
}
variable "private_key_path" {
  default = ""
}
variable "private_key_password" {
  default = ""
}
variable "region" {
  validation {
    condition     = length(trim(var.region, "")) > 0
    error_message = "Validation failed for region: value is required."
  }
}
variable "service_label" {
  validation {
    condition     = length(regexall("^[A-Za-z][A-Za-z0-9]{1,19}$", var.service_label)) > 0
    error_message = "Validation failed for service_label: value is required and must contain alphanumeric characters only, starting with a letter up to a maximum of 20 characters."
  }
}

variable "homeregion" {
  type        = bool
  description = "Home Region Deployment"
}

# ------------------------------------------------------
# ----- SIEM Integration
# ------------------------------------------------------

variable "integration_type" {
  description = "Select an integration pattern to provision in your tenancy."
  type        = string
  #default     = null
}

#*************
# Stream Based
variable "compartment_id_for_stream" {
  description = "The compartment where the stream should reside."
  type        = string
  default     = null
}

variable "name_for_stream" {
  description = "Customize the stream name. Service Label will be prefixed."
  type        = string
  default     = "siem-integration-stream"
}

variable "compartment_id_for_service_connector_stream" {
  description = "The compartment where the Service Connector should reside."
  type        = string
  default     = null
}

variable "name_for_service_connector_stream" {
  description = "Customize the service connector name. Service Label will be prefixed."
  type        = string
  default     = "audit_logs_to_stream"
}

variable "create_iam_resources_stream" {
  type        = bool
  description = "Create a group in the Default Identity Domain and the required IAM Stream read policy. The IAM policy will be created in the same compartment as the stream."
  default     = null
}

variable "access_method_stream" {
  description = "Select how the SIEM will access OCI APIs."
  type        = string
  default     = "API Signing Key"
}

variable "stream_partitions_count" {
  description = "Number of partitions in the stream. Default to 1."
  type        = number
  default     = 1
}

variable "stream_retention_in_hours" {
  description = "Stream retention in hours. Default 24 hours."
  type        = number
  default     = 24
}


# *****************
# Logging Analytics
variable "create_iam_resources_la" {
  type    = bool
  default = null
}



variable "integration_link" {
  description = "Select an integration pattern to provision in your tenancy."
  type        = string
  default     = null
}

variable "integration_info" {
  description = "Information needed to configure the Integration on the SIEM Side."
  type        = list(string)
  default     = null
}




#variable "compartment_id_for_logs" {
#  description = "The compartment where logs should reside"
#  type        = list(string)
#  default     = ["ocid1.compartment.oc1..aaaaaaaa63q5blq6gcobbxz5vmnfhfvncrc7o2cdwpeg2p5qmobsivv23vtq", "ocid1.compartment.oc1..aaaaaaaaqyepbq6q3kr5kq5wvp2c5ih65l4h6n2g4rp3vhtxxn6mbhm2yega"]
#}
