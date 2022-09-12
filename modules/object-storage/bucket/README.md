## CIS OCI Landing Zone Object Storage Buckets Module.

This module manages OCI Object Storage buckets resources per CIS OCI Benchmark.  
The buckets are encrypted by the provided key ocid given in var.buckets' kms\_key\_id.  
If cis\_level = 1 and kms\_key\_id is not provided, the bucket is encrypted with an Oracle managed key.  
If cis\_level = 2 and kms\_key\_id is not provided, the module produces an error.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| oci | n/a |

## Modules

No Modules.

## Resources

| Name |
|------|
| [oci_objectstorage_bucket](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/objectstorage_bucket) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| buckets | The buckets to manage. | <pre>map(object({<br>    compartment_id = string,<br>    name           = string,<br>    namespace      = string,<br>    kms_key_id     = string,<br>    defined_tags   = map(string),<br>    freeform_tags   = map(string)<br>  }))</pre> | n/a | yes |
| cis\_level | The CIS OCI Benchmark profile level for buckets. Level 1 is be practical and prudent. Level 2 is intended for environments where security is more critical than manageability and usability. | `string` | `"2"` | no |

## Outputs

| Name | Description |
|------|-------------|
| buckets | The buckets, indexed by bucket name. |
