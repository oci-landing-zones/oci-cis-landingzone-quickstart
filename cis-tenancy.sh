#!/bin/bash

# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### Sample script to show how to execute the Terraform configurations.
### When creating, it's usually not advisable to run 'terraform apply --auto-approve'. 
### It's always preferable to run 'terraform plan' for checking what Terraform will do during the apply phase.

if [ $# -eq 0 ] 
then
    echo "Usage: $0 create or $0 destroy"
    echo "Exiting..."
    exit 1
elif [ $1 == 'create' ] 
then
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
elif [ $1 == 'destroy' ] 
then
    cd cis-monitoring
    terraform destroy
    cd ../cis-object-storage
    terraform destroy
    cd ../cis-network
    terraform destroy
    cd ../cis-iam
    terraform destroy
    cd ..  
else
    echo "Nothing to do. Exiting..."      
fi