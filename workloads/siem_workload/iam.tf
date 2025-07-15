# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.


locals {

  groups_configuration = {
    default_defined_tags : null
    default_freeform_tags : null
    groups : {
      STREAM-READ-GROUP : {
        name : "${var.service_label}-stream-read-group",
        description : "Allow members to read messages from stream"
        #members : [], 
        #defined_tags : null, 
        #freeform_tags : null
      }
    }
  }

  dynamic_groups_configuration = {
    #default_defined_tags = null
    #default_freeform_tags = null
    dynamic_groups = {
      STREAM-READ-DYN-GROUP : {
        name : "${var.service_label}-stream-read-dynamic-group",
        description : "Dynamic group including instances in a compartment used for reading messages from stream.",
        matching_rule : "ALL {resource.type = 'instance',resource.compartment.id = '${var.compartment_id_for_stream}'}"
        #defined_tags : null, 
        #freeform_tags : null
      }
    }
  }

  #iam_policy_api_key            = "allow group ${local.groups_configuration.groups.STREAM-READ-GROUP.name} to use stream-pull in compartment id ${var.compartment_id_for_stream} where all {target.stream.id='${module.vision_streams[0].streams.SIEM-INTEGRATION-STREAM.id}'}"
  #iam_policy_instance_principal = "allow dynamic-group ${local.dynamic_groups_configuration.dynamic_groups.STREAM-READ-DYN-GROUP.name} to use stream-pull in compartment id ${var.compartment_id_for_stream} where all {target.stream.id='${module.vision_streams[0].streams.SIEM-INTEGRATION-STREAM.id}'}"



  policies_configuration = {
    supplied_policies : {
      "READ-STREAM" : {
        name : "${var.service_label}-siem-stream-read"
        description : "Policy allowing the ${var.access_method_stream == "API Signing Key" ? local.groups_configuration.groups.STREAM-READ-GROUP.name : local.dynamic_groups_configuration.dynamic_groups.STREAM-READ-DYN-GROUP.name} group to read messages from stream."
        compartment_id : var.compartment_id_for_stream # Instead of an OCID, you can replace it with the string "TENANCY-ROOT" for attaching the policy to the Root compartment.
        statements : [
          var.access_method_stream == "API Signing Key" ? lookup(local.siem_info, var.integration_type).iam_policy_api_key : lookup(local.siem_info, var.integration_type).iam_policy_instance_principal
        ]
      }
    }
  }
}

module "vision_iam_policies" {
  source                 = "github.com/oracle-quickstart/terraform-oci-cis-landing-zone-iam//policies?ref=v0.2.1"
  count                  = (var.create_iam_resources_stream == true && var.homeregion == true) ? 1 : 0
  tenancy_ocid           = var.tenancy_ocid
  policies_configuration = local.policies_configuration
}


module "vision_groups" {
  source               = "github.com/oracle-quickstart/terraform-oci-cis-landing-zone-iam//groups?ref=v0.2.1"
  count                = (var.create_iam_resources_stream == true && var.access_method_stream == "API Signing Key" && var.homeregion == true) ? 1 : 0
  tenancy_ocid         = var.tenancy_ocid
  groups_configuration = local.groups_configuration
}

module "vision_dynamic_groups" {
  source                       = "github.com/oracle-quickstart/terraform-oci-cis-landing-zone-iam//dynamic-groups?ref=v0.2.1"
  count                        = (var.create_iam_resources_stream == true && var.access_method_stream == "Instance Principal" && var.homeregion == true) ? 1 : 0
  tenancy_ocid                 = var.tenancy_ocid
  dynamic_groups_configuration = local.dynamic_groups_configuration
}
