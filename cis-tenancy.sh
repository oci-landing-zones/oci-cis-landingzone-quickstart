#!/bin/bash
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