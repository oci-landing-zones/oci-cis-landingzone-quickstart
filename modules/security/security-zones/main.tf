# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals ={
    cis_1_2_L2 = [
        "ocid1.securityzonessecuritypolicy.oc1..aaaaaaaa5ocyo7jqjzgjenvccch46buhpaaofplzxlp3xbxfcdwwk2tyrwqa",
        "ocid1.securityzonessecuritypolicy.oc1..aaaaaaaauoi2xnbusvfd4yffdjaaazk64gndp4flumaw3r7vedwndqd6vmrq"
                        ]
    cis_1_2_L1 = [
        "ocid1.securityzonessecuritypolicy.oc1..aaaaaaaa7pgtjyod3pze6wuylgmts6ensywmeplabsxqq2bk4ighps4fqq4a",
        "ocid1.securityzonessecuritypolicy.oc1..aaaaaaaaxxs63ulmtcnxqmcvy6eaozh5jdtiaa2bk7wll5bbdsbnmmoczp5a",
        "ocid1.securityzonessecuritypolicy.oc1..aaaaaaaaqmq4jqcxqbjj5cjzb7t5ira66dctyypq2m2o4psxmx6atp45lyda",
        "ocid1.securityzonessecuritypolicy.oc1..aaaaaaaaff6n52aojbgdg46jpm3kn7nizmh6iwvr7myez7svtfxsfs7irigq",
    ]

    sz_policies = var.cis_level == "2" ? setunion(cis_1_2_L2,cis_1_2_L1,var.security_policies) : setunion(cis_1_2_L1,var.security_policies)

}


resource "oci_cloud_guard_security_recipe" "this" {
    #Required
    compartment_id = var.compartment_id
    display_name = var.security_recipe_display_name
    security_policies = local.sz_policies

    #Optional
    defined_tags = var.defined_tags
    description = "${var.description} recipe."
    freeform_tags = var.defined_tags
}

resource "oci_cloud_guard_security_zone" "this" {
    #Required
    compartment_id = var.compartment_id
    display_name = var.security_zone_display_name
    security_zone_recipe_id = oci_cloud_guard_security_zone_recipe.test_security_zone_recipe.id

    #Optional
    defined_tags = var.defined_tags
    description = "${var.description}."
    freeform_tags = var.defined_tags
}