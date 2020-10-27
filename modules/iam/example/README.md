### Create Compartment, User, Group and Dynamic Group
This example shows how to reference an existing compartment as a resource (compartment_create = false), or if a compartment needs to be created, please set compartment_create = true.
Also this example shows how to create two users, a group and add two users to it, and create a policy pertaining to a compartment and group, and some more directives to show dynamic groups and policy for it.

Note: the compartment resource internally resolves name collisions and returns a reference to the preexisting compartment. Compartments can not be deleted, so removing a compartment resource from your .tf file will only remove it from your statefile. User, group and dynamic group created by this example can be deleted by using terrafrom destroy.

### Using this example
* Prepare one variable file named "terraform.tfvars" with the required information. And the content of "terraform.tfvars" looks like below:
```
$ cat terraform.tfvars
# OCI Authentication details
tenancy_ocid = "ocid1.tenancy.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
compartment_ocid = "ocid1.compartment.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
user_ocid = "ocid1.user.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
fingerprint= "xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx"
private_key_path = "~/.oci/oci_api_key.pem"

# Region
region = "us-phoenix-1"
```

* Run this example you need to execute:

```
$ terraform init
```
* View what Terraform plans do before actually doing it:
```
$ terraform plan
```
* Use Terraform to Provision resources on OCI:
```
$ terraform apply
```
