#!/bin/bash

### Sample script to show how to execute the Terraform configurations.
### It's usually not advisable to run 'terraform apply --auto-approve'. 
### It's always preferable to run 'terraform plan' for checking what Terraform will do during the apply phase.

source env-vars.ateamocidev.dev.iad
cd cis-iam
terraform init
terraform apply --auto-approve
cd ../cis-network
terraform init
terraform apply --auto-approve
cd ../cis-object-storage
terraform init
terraform apply --auto-approve
cd ../cis-monitoring
terraform init
terraform apply --auto-approve
cd ..