# June 2021 Release Notes
1. [Logging Consolidation with Service Connector Hub](#logging_consolidation)
2. [Vulnerability Scanning](#vulnerability_scanning)
	
## <a name="logging_consolidations"></a>1. Logging Consolidation with Service Connector Hub
The Landing Zone enables/collects logs for a few services, like VCN and Audit services. From a governance perspective, it's interesting that these logs get consolidated and made available to security management tools. This capability is now availabe in the Landing Zone with the Service Connector Hub, that reads logs from different sources and sends them to a target that the user chooses. By default, this target is a bucket in the Object Storage service, but functions and streams can also be configured as targets. As the usage of a bucket, function or stream may incur in costs to our customers, Landing Zone users must explicitly activate Service Connector Hub by setting variables in the Terraform configuration, as described in [Logging Variables](terraform.md#logging_variables) section.

To delete or change a Service Connector that has an Object Storage bucket as a target, you must manually remove the target from the Service Connector and manually delete the bucket. A bucket with objects cannot be deleted via Terraform.

## <a name="vulnerability_scanning"></a>2. Vulnerability Scanning
The Landing Zone now enables scanning through the Vulnerability Scanning Service (VSS), creating a scan recipe and scan targets by default. The recipe is set to run every week on sundays and the targets are set to all four Landing Zone compartments. Running the Landing Zone as is, weekly scans are automatically executed for any instances deployed in any of the Landing Zone compartments. The scan results are made available in the Security compartment and can be verified in the OCI Console. 

Scanning can be disabled in the Landing Zone, and the scan frequency and targets can be changed as well. Disabling scanning and changing the frequency are controlled by setting variables in the Terraform configuration, as described in [Scanning Variables](terraform.md#vss_variables) section, while targets can be changed in the vss.tf file. The Vulnerability Scanning Service is free. 